#!/usr/bin/env python3
"""Install missing tools from shared LSP, EFM and coc profile metadata.

Usage: python scripts/install-lsp-tools.py [--dry-run]
Only explicit install commands are used; package names never imply binaries.
Dry-run performs no subprocess calls. Exit status 1 indicates invalid metadata
or a failed install. Missing PyYAML skips EFM metadata with a warning.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys

try:
    import yaml
except ImportError:
    yaml = None

VIM_DIR = Path(__file__).resolve().parent.parent


def load_jsonc(path):
    # Tokenize strings before comments, so URLs, escaped quotes and comment-like
    # text inside strings survive. Removing comments must not join adjacent tokens.
    tokens = re.findall(
        r'"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*[\s\S]*?\*/|\s+|.',
        path.read_text(encoding="utf-8-sig"),
    )
    tokens = [
        " " if token.startswith(("//", "/*")) else token for token in tokens
    ]
    significant = [i for i, token in enumerate(tokens) if not token.isspace()]
    for left, right in zip(significant, significant[1:]):
        if tokens[left] == "," and tokens[right] in ("]", "}"):
            tokens[left] = ""
    return json.loads("".join(tokens))


def expand_binary(binary):
    return os.path.expanduser(os.path.expandvars(binary))


def check_binary(check):
    """Recognize declarative executable checks without executing shell code."""
    if not isinstance(check, str):
        return None
    try:
        parts = shlex.split(check)
    except ValueError:
        return None
    if len(parts) == 2 and parts[0] in ("which", "where"):
        return parts[1]
    if len(parts) == 3 and parts[:2] == ["command", "-v"]:
        return parts[2]
    return None


def install_key(command):
    parts = shlex.split(command)
    if parts[:2] == ["npm", "i"]:
        parts[1] = "install"
    return tuple(parts)


def actionable_source(command):
    if not isinstance(command, str):
        return False
    try:
        parts = install_key(command)
    except ValueError:
        return False
    prefixes = (
        ("npm", "install"), ("pipx", "install"),
        ("pip", "install"), ("pip3", "install"), ("go", "install"),
        ("dotnet", "tool", "install"), ("cargo", "install"),
        ("gem", "install"), ("brew", "install"),
    )
    return any(parts[:len(prefix)] == prefix for prefix in prefixes)


def tool_metadata(root):
    """Yield (label, executable, explicit installation command)."""
    path = root / "lsp-servers.json"
    if path.exists():
        for server in load_jsonc(path).get("servers", []):
            cmd = server.get("cmd")
            if isinstance(cmd, list) and cmd and server.get("install"):
                yield server["name"], cmd[0], server["install"]

    path = root / "efm-langserver-config.yaml"
    if path.exists():
        if yaml is None:
            print("WARNING: PyYAML unavailable; skipping EFM tools. Install PyYAML "
                  "in your Python environment to include them.", file=sys.stderr)
        else:
            try:
                data = yaml.safe_load(path.read_text(encoding="utf-8"))
            except yaml.YAMLError as exc:
                raise ValueError(f"Invalid YAML in {path}: {exc}") from exc
            tools = (data or {}).get("tools") or {}
            for name, tool in sorted(tools.items()):
                if not isinstance(tool, dict) or not tool.get("install"):
                    continue
                binary = check_binary(tool.get("checkInstalled"))
                if not binary:
                    print(f"WARNING: Skipping {name}: no supported explicit executable "
                          "check (which/where/command -v).", file=sys.stderr)
                    continue
                yield name, binary, tool["install"]


def profile_metadata(root):
    for path in sorted((root / "coc-profiles").glob("*/coc-settings.json")):
        for name, server in (load_jsonc(path).get("languageserver") or {}).items():
            if not isinstance(server, dict) or server.get("disabled"):
                continue
            binary = server.get("command")
            if not isinstance(binary, str) or not binary:
                continue
            sources = server.get("sources") or []
            if isinstance(sources, str):
                sources = [sources]
            commands = [source.strip() for source in sources if actionable_source(source)]
            label = f"{path.parent.name}:{name}"
            if not commands and not shutil.which(expand_binary(binary)):
                print(f"WARNING: {label}: missing {binary}; no runnable install source.",
                      file=sys.stderr)
            for command in commands:
                yield label, binary, command


def main(argv=None, root=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    root = Path(root) if root is not None else VIM_DIR
    try:
        shared = list(tool_metadata(root))
        # Prefer the explicit executable from shared metadata for auxiliary
        # tools mentioned in profiles (e.g. eslint_d alongside efm-langserver).
        known = {install_key(command): (name, binary, command)
                 for name, binary, command in shared}
        tools = shared + [known.get(install_key(tool[2]), tool)
                          for tool in profile_metadata(root)]
    except (OSError, ValueError, TypeError, KeyError) as exc:
        print(f"WARNING: Cannot read install metadata: {exc}", file=sys.stderr)
        return 1

    attempted = set()
    failures = []
    for name, binary, command in tools:
        if shutil.which(expand_binary(binary)):
            continue
        key = install_key(command)
        if key in attempted:
            continue
        attempted.add(key)
        if args.dry_run:
            print(f"Would install '{name}' (missing {binary}): {command}")
            continue
        print(f"Installing '{name}' (missing {binary}): {command}")
        try:
            result = subprocess.run(command, shell=True)
            success = result.returncode == 0
            detail = f"exit status {result.returncode}"
        except OSError as exc:
            success = False
            detail = str(exc)
        if not success:
            failures.append(name)
            print(f"WARNING: install failed for '{name}': {detail}", file=sys.stderr)
    if failures:
        print("Failed: " + ", ".join(failures), file=sys.stderr)
        return 1
    if not attempted:
        print("No missing tools with runnable install metadata.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
