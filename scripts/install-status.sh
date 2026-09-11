#!/bin/bash
# Functions only: the installer owns the failure list and execution order.
install_step() {
  local label="$1" status
  shift
  if "$@"; then
    return 0
  else
    status=$?
    INSTALL_FAILURES+=("$label (exit $status)")
    printf 'ERROR: %s (exit %s)\n' "$label" "$status" >&2
    return "$status"
  fi
}

install_plugins() {
  local editor="$1" script="$2" log="$3" status
  local command=("$editor")
  if [[ "$(basename "$editor")" = nvim* ]]; then
    command+=(--headless)
  else
    command+=(-es)
  fi
  command+=(-i NONE -n -V1 -S "$script")
  if TERM=ansi "${command[@]}" >"$log" 2>&1; then
    printf 'Plugin installation completed. Log: %s\n' "$log"
    return 0
  else
    status=$?
    printf 'ERROR: Plugin installation failed. Log: %s\n' "$log" >&2
    cat -- "$log" >&2
    return "$status"
  fi
}

install_summary() {
  if [ "${#INSTALL_FAILURES[@]}" -gt 0 ]; then
    printf 'Installation incomplete:\n' >&2
    printf '  - %s\n' "${INSTALL_FAILURES[@]}" >&2
    return 1
  fi
  printf 'Installation completed; optional omissions are listed above.\n'
}
