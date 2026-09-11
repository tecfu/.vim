#!/usr/bin/env bash
# CI checks for installer metadata (lsp-servers.json + efm-langserver-config.yaml).
# Fails if Python tools still use bare `pip install` (PEP 668 regression).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON="${PYTHON:-python3}"
FAIL=0

pass() { echo "  OK  $*"; }
fail() { echo "  FAIL $*"; FAIL=1; }

echo "==> Validate lsp-servers.json"
if "$PYTHON" -c 'import json, sys; json.load(open(sys.argv[1]))' "$ROOT/lsp-servers.json"; then
  pass "lsp-servers.json is valid JSON"
else
  fail "lsp-servers.json is not valid JSON"
fi

echo "==> Validate efm-langserver-config.yaml"
if "$PYTHON" -c 'import yaml, sys; yaml.safe_load(open(sys.argv[1]))' "$ROOT/efm-langserver-config.yaml"; then
  pass "efm-langserver-config.yaml is valid YAML"
else
  fail "efm-langserver-config.yaml is not valid YAML (is PyYAML installed?)"
fi

echo "==> PEP 668 regression: Python install commands must use pipx (not pip install --user / bare pip)"
BAD_FILE="$(mktemp)"
trap 'rm -f -- "$BAD_FILE"' EXIT
"$PYTHON" - "$ROOT" "$BAD_FILE" <<'PY'
import json, yaml, sys
root, bad_file = sys.argv[1:]
bad = []
with open(f"{root}/lsp-servers.json") as f:
    for s in json.load(f).get("servers", []):
        inst = (s.get("install") or "").strip()
        if inst.startswith("pip ") or "pip install" in inst:
            bad.append(f"{s.get('name', '?')}: {inst}")
with open(f"{root}/efm-langserver-config.yaml") as f:
    tools = (yaml.safe_load(f) or {}).get("tools") or {}
    for name, tool in tools.items():
        if not isinstance(tool, dict):
            continue
        inst = (tool.get("install") or "").strip()
        if inst.startswith("pip ") or "pip install" in inst:
            bad.append(f"{name}: {inst}")
open(bad_file, "w").write("\n".join(bad))
sys.exit(0)
PY

if [[ -s "$BAD_FILE" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && fail "still uses pip (should be pipx): $line"
  done < "$BAD_FILE"
else
  pass "no bare 'pip install' install commands for Python tools"
fi
rm -f "$BAD_FILE"

echo "==> Expected pipx install targets are present"
for pkg in basedpyright ruff black mypy flake8; do
  if grep -rq "pipx install $pkg" "$ROOT/lsp-servers.json" "$ROOT/efm-langserver-config.yaml"; then
    pass "pipx install $pkg declared"
  else
    fail "missing pipx install for $pkg"
  fi
done

echo "==> install-lsp-tools.py --dry-run (if deps available)"
if "$PYTHON" -c "import yaml" 2>/dev/null; then
  set +e
  "$PYTHON" "$ROOT/scripts/install-lsp-tools.py" --dry-run
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    pass "install-lsp-tools.py --dry-run exited 0"
  else
    fail "install-lsp-tools.py --dry-run failed (exit $rc)"
  fi
else
  fail "PyYAML not available for install-lsp-tools.py"
fi

if ((FAIL)); then
  echo
  echo "CI metadata checks FAILED"
  exit 1
fi
echo
echo "CI metadata checks PASSED"
exit 0
