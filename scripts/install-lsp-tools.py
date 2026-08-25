#!/usr/bin/env python3
"""Install every missing tool declared in this dotfiles repo.

Single consumer of the install metadata:
  - lsp-servers.json            -> servers[].install   (real language servers)
  - efm-langserver-config.yaml  -> tools.*.checkInstalled / .install (lint/format tools)

Usage: install-lsp-tools.py [--dry-run]
Exit code: 0 = nothing missing or all installs succeeded, 1 = failures.
"""
import json
import os
import shutil
import subprocess
import sys

import yaml

VIM_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def sh(cmd: str) -> bool:
    return subprocess.run(cmd, shell=True).returncode == 0


def main() -> int:
    dry_run = "--dry-run" in sys.argv
    pending = []

    # Real language servers (lsp-servers.json)
    with open(os.path.join(VIM_DIR, "lsp-servers.json")) as f:
        for server in json.load(f).get("servers", []):
            binary, install = server["cmd"][0], server.get("install")
            if not shutil.which(binary) and install:
                pending.append((server["name"], install))

    # Lint/format tools (efm yaml custom fields)
    with open(os.path.join(VIM_DIR, "efm-langserver-config.yaml")) as f:
        tools = (yaml.safe_load(f) or {}).get("tools") or {}
    for name, tool in sorted(tools.items()):
        if not isinstance(tool, dict):
            continue
        check, install = tool.get("checkInstalled"), tool.get("install")
        if not install:
            continue
        if not sh(check or f"which {name}"):
            pending.append((name, install))

    if not pending:
        print("All configured LSP/lint/format tools are present.")
        return 0

    failures = []
    for name, install in pending:
        print(f"Installing '{name}': {install}")
        if not dry_run and not sh(install):
            failures.append((name, install))
            print(f"WARNING: install failed for '{name}'", file=sys.stderr)

    if failures:
        print("\nFailed: " + ", ".join(n for n, _ in failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
