#!/usr/bin/env bash
# Usage: efm-stdin-file-wrapper.sh <linter-command> ... $tempfile
# Example: efm-stdin-file-wrapper.sh npx basedpyright --outputjson $tempfile

set -e

tmpfile=$(mktemp --suffix=.tmp)
cat > "$tmpfile"

args=()
for arg in "$@"; do
  if [[ "$arg" == "\$tempfile" || "$arg" == "{INPUT}" ]]; then
    args+=("$tmpfile")
  else
    args+=("$arg")
  fi
done

"${args[@]}"
status=$?

rm -f "$tmpfile"
exit $status
