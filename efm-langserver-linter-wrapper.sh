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
#                               Empty means exactly one positional argument;
#                               other arguments must be switches or --key=value.
#                               Use -- before it if options take separate values.
#                               A flag accepts --flag=value or --flag value.
#                               Other prefixes are matched literally.
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
  MATCHED_FILES=()
  POSITIONAL_ONLY=false
  POSITIONAL_START=1
  if [ -z "$FILENAME_ARG_PREFIX" ]; then
    # An explicit separator makes preceding option values unambiguous.
    for ((i=1; i<${#LINTER_COMMAND_AND_ARGS[@]}; i++)); do
      if [[ "${LINTER_COMMAND_AND_ARGS[i]}" == -- ]]; then
        POSITIONAL_START=$((i + 1))
        POSITIONAL_ONLY=true
        break
      fi
    done
  fi
  for ((i=POSITIONAL_START; i<${#LINTER_COMMAND_AND_ARGS[@]}; i++)); do
    arg="${LINTER_COMMAND_AND_ARGS[i]}"
    if [ -z "$FILENAME_ARG_PREFIX" ]; then
      if [ "$POSITIONAL_ONLY" = true ] || [[ "$arg" != -* ]]; then
        MATCHED_FILES+=("$arg")
      fi
    elif [[ "$arg" == -- ]]; then
      break
    elif [[ "$arg" == "$FILENAME_ARG_PREFIX" ]]; then
      if [[ "$FILENAME_ARG_PREFIX" != -* || "$FILENAME_ARG_PREFIX" == *[=:] ]]; then
        MATCHED_FILES+=("")
      elif ((i + 1 < ${#LINTER_COMMAND_AND_ARGS[@]})) && [[ "${LINTER_COMMAND_AND_ARGS[i+1]}" != -* ]]; then
        i=$((i + 1))
        MATCHED_FILES+=("${LINTER_COMMAND_AND_ARGS[i]}")
      else
        log_error "Missing filename after '$FILENAME_ARG_PREFIX'."
        exit 1
      fi
    elif [[ "$FILENAME_ARG_PREFIX" == -* && "$FILENAME_ARG_PREFIX" != *= && "$arg" == "$FILENAME_ARG_PREFIX="* ]]; then
      MATCHED_FILES+=("${arg#"$FILENAME_ARG_PREFIX="}")
    elif [[ "$FILENAME_ARG_PREFIX" != --* || "$FILENAME_ARG_PREFIX" == *[=:] ]]; then
      if [[ "$arg" == "$FILENAME_ARG_PREFIX"* ]]; then
        MATCHED_FILES+=("${arg#"$FILENAME_ARG_PREFIX"}")
      fi
    fi
  done
  if [ ${#MATCHED_FILES[@]} -ne 1 ] || [ -z "${MATCHED_FILES[0]}" ]; then
    log_error "Expected exactly one filename in linter arguments using prefix '$FILENAME_ARG_PREFIX'; found ${#MATCHED_FILES[@]}."
    exit 1
  fi
  FILE_TO_LINT="${MATCHED_FILES[0]}"
  log_info "Identified file to lint: $FILE_TO_LINT"
  if command -v cygpath >/dev/null 2>&1; then
    FILE_TO_LINT=$(cygpath -u "$FILE_TO_LINT")
  fi
  if ! SEARCH_START_DIR=$(cd -- "$(dirname -- "$FILE_TO_LINT")" && pwd -P); then
    log_error "Cannot resolve directory for filename '$FILE_TO_LINT'."
    exit 1
  fi
else
  log_info "No filename prefix provided; assuming project-wide linter."
  SEARCH_START_DIR=$(pwd -P)
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
  local dir="$1" parent
  while :; do
    if check_dir_for_config "$dir"; then
      log_info "Found project-local config in '$dir'."
      return 0
    fi
    parent=$(dirname -- "$dir")
    if [[ "$parent" == "$dir" || "$parent" == "." ]]; then break; fi
    # MSYS drive roots are mount points, not children of the MSYS root.
    if [[ "$dir" =~ ^/[a-zA-Z]$ ]] && command -v cygpath >/dev/null 2>&1; then break; fi
    dir="$parent"
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
