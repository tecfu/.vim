#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Definitive Generic Linter Wrapper Script for EFM-Langserver
# -----------------------------------------------------------------------------
#
# This script intelligently decides whether to use a project-local configuration
# for a linter, or fall back to a specified global-style configuration.
#
# It is designed to be called by efm-langserver and solves a critical problem:
# how to support both project-specific rules and a consistent global fallback.
#
# It correctly handles three types of linters:
# 1. Project-wide linters that don't take a filename (e.g., `golangci-lint`).
# 2. Daemonized linters using --stdin with a filename for context (e.g., `eslint_d`).
# 3. Simple linters that take a filename as an argument (e.g., `rubocop`).
#
# --- USAGE ---
#
# ./efm-langserver-linter-wrapper.sh [OPTIONS] -- [LINTER_COMMAND_AND_ARGS]
#
# --- OPTIONS ---
#
#   --filenames=<files>       (Required) A comma-separated list of config
#                               filenames to search for.
#   --fallback-config=<path>  (Required) The full path to the fallback
#                               configuration file to use.
#   --config-flag=<flag>      (Required) The flag the linter uses to specify a
#                               config file (e.g., "-c", "--config").
#   --filename-arg-prefix=<p> (Optional) The prefix for the filename arg.
#                               Omit this for project-wide linters.
#
# -----------------------------------------------------------------------------

set -e

# --- Initializations ---
readonly SCRIPT_NAME=$(basename "$0")
FILENAMES=""
FALLBACK_CONFIG=""
FILENAME_ARG_PREFIX_SET=false
FILENAME_ARG_PREFIX=""
CONFIG_FLAG=""
LINTER_COMMAND_AND_ARGS=()

# --- Helper Functions ---
_log() { local level="$1"; shift; local ts; ts=$(date '+%Y-%m-%dT%H:%M:%S'); echo "$ts $SCRIPT_NAME [$level]: $@" >&2; }
log_info() { _log "INFO" "$@"; }
log_error() { _log "ERROR" "$@"; }
usage() {
  log_error "Incorrect usage."
  sed -n '/^# --- USAGE ---/,/^# --- OPTIONS ---/p' "$0" | sed 's/^#//' >&2
}

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --filenames=*) FILENAMES="${1#*=}"; shift ;;
    --fallback-config=*) FALLBACK_CONFIG="${1#*=}"; shift ;;
    --config-flag=*) CONFIG_FLAG="${1#*=}"; shift ;;
    --filename-arg-prefix=*) FILENAME_ARG_PREFIX="${1#*=}"; FILENAME_ARG_PREFIX_SET=true; shift ;;
    --) shift; LINTER_COMMAND_AND_ARGS=("$@"); break ;;
    *) log_error "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# --- Argument Validation ---
MISSING_ARGS=()
if [ -z "$FILENAMES" ]; then MISSING_ARGS+=("--filenames"); fi
if [ -z "$FALLBACK_CONFIG" ]; then MISSING_ARGS+=("--fallback-config"); fi
if [ -z "$CONFIG_FLAG" ]; then MISSING_ARGS+=("--config-flag"); fi

if [ ${#MISSING_ARGS[@]} -gt 0 ]; then
  log_error "The following required options are missing: ${MISSING_ARGS[*]}"
  usage
  exit 1
fi
if [ ${#LINTER_COMMAND_AND_ARGS[@]} -eq 0 ]; then
  log_error "Linter command is missing. It must be provided after '--'."
  usage
  exit 1
fi

# --- Core Logic ---
SEARCH_START_DIR=""
if [ "$FILENAME_ARG_PREFIX_SET" = true ]; then
  FILE_TO_LINT=""
  for arg in "${LINTER_COMMAND_AND_ARGS[@]}"; do
    if [[ "$arg" == "$FILENAME_ARG_PREFIX"* ]]; then
      FILE_TO_LINT="${arg#"$FILENAME_ARG_PREFIX"}"
      break
    fi
  done
  if [ -z "$FILE_TO_LINT" ]; then
    log_error "Could not find filename in linter arguments using prefix '$FILENAME_ARG_PREFIX'."
    exec "${LINTER_COMMAND_AND_ARGS[@]}"
  fi
  log_info "Identified file to lint: $FILE_TO_LINT"
  SEARCH_START_DIR=$(dirname "$FILE_TO_LINT")
else
  log_info "No filename prefix provided; assuming project-wide linter."
  SEARCH_START_DIR=$(pwd)
fi
log_info "Using search root: $SEARCH_START_DIR"
IFS=',' read -r -a FILENAMES_ARRAY <<< "$FILENAMES"
check_dir_for_config() {
  local dir_to_check="$1"
  for name in "${FILENAMES_ARRAY[@]}"; do
    if [ -f "$dir_to_check/$name" ]; then return 0; fi
  done
  return 1
}
find_native_config() {
  local dir="$1"
  while [ "$dir" != "/" ] && [ "$dir" != "." ]; do
    if check_dir_for_config "$dir"; then
      log_info "Found project-local config in '$dir'."
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# --- Execution ---
log_info "Linter command: ${LINTER_COMMAND_AND_ARGS[*]}"
if find_native_config "$SEARCH_START_DIR"; then
  log_info "Executing linter normally to use the native config."
  exec "${LINTER_COMMAND_AND_ARGS[@]}"
else
  log_info "No native config found. Falling back to: $FALLBACK_CONFIG"
  if [ ! -f "$FALLBACK_CONFIG" ]; then
    log_error "The specified fallback config file does not exist!"
    exit 1
  fi
  exec "${LINTER_COMMAND_AND_ARGS[0]}" "$CONFIG_FLAG" "$FALLBACK_CONFIG" "${LINTER_COMMAND_AND_ARGS[@]:1}"
fi
