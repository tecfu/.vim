#!/usr/bin/env python3
"""Run isolated native editor regressions, without plugins or package installs.

Mode tests source the real entry/config files. Unrelated plugin modules and the
vim-plug/CoC/cmp APIs are fixtures; Neovim's LSP, diagnostics and buffer APIs are
real and communicate with a local stdio LSP fixture. This is configuration and
protocol coverage, not a replacement for testing installed third-party plugins.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import uuid


ROOT = Path(__file__).resolve().parent.parent
MODE_FILES = {
    "viml/coc-nvim.vim",
    "viml/nvim-cmp.nvim",
    "viml/nvim-lsp-builtin.nvim",
    "viml/nvim-lsp-efm.nvim",
    "viml/nvim-lsp-diagnostic-window.nvim",
}


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def environment(work):
    env = os.environ.copy()
    for key in ("VIMINIT", "EXINIT", "GVIMINIT", "MYVIMRC", "VIM_PROFILE",
                "NVIM_CONFIG", "COC_PROFILE", "NVIM", "NVIM_APPNAME",
                "VIM", "VIMRUNTIME"):
        env.pop(key, None)
    home = work / "home with spaces"
    for key, path in {
        "HOME": home, "USERPROFILE": home,
        "XDG_CONFIG_HOME": home / "config",
        "XDG_DATA_HOME": home / "data",
        "XDG_STATE_HOME": home / "state",
        "XDG_CACHE_HOME": home / "cache",
        "APPDATA": home / "appdata",
        "LOCALAPPDATA": home / "localappdata",
        "TMPDIR": work / "scratch", "TMP": work / "scratch",
        "TEMP": work / "scratch",
    }.items():
        path.mkdir(parents=True, exist_ok=True)
        env[key] = path.as_posix()
    # Native Neovim needs a shell and flags from the same platform, even when
    # launched by Git Bash or a CLI that exports SHELL on Windows.
    if os.name == "nt":
        env.pop("SHELL", None)
    env["VIM_TEST_ROOT"] = ROOT.as_posix()
    env["VIM_TEST_WORK"] = work.as_posix()
    env["VIM_TEST_PYTHON"] = sys.executable
    return env


def mode_home(env):
    home = Path(env["HOME"])
    config = home / ".vim"
    for entry in ("config-nvim.vim", "config-vim.vim"):
        content = (ROOT / entry).read_text(encoding="utf-8")
        write(config / entry, content)
        # Only unrelated plugin configuration is replaced, never mode branches.
        for relative in re.findall(r"^\s*source \$HOME/\.vim/(\S+)", content, re.M):
            if relative not in MODE_FILES:
                write(config / relative, '" Unrelated plugin fixture.\n')
    for relative in MODE_FILES:
        write(config / relative, (ROOT / relative).read_text(encoding="utf-8"))
    shutil.copytree(ROOT / "coc-profiles", config / "coc-profiles")
    shutil.copy2(ROOT / "efm-langserver-config.yaml", config)
    registry = json.loads((ROOT / "lsp-servers.json").read_text(encoding="utf-8"))
    for server in registry["servers"]:
        server["cmd"] = [sys.executable, str(ROOT / "scripts" / "test-modes-lsp.py"),
                         server["name"]]
        server.pop("install", None)
    write(config / "lsp-servers.json", json.dumps(registry))
    write(config / "autoload" / "plug.vim", """
function! plug#begin(...) abort
  command! -nargs=+ Plug let g:test_plug_declarations += 1
endfunction
function! plug#end(...) abort
endfunction
function! plug#load(...) abort
  for l:item in a:000
    call extend(g:test_plug_loads, type(l:item) == v:t_list ? l:item : [l:item])
  endfor
endfunction
""")
    write(config / "autoload" / "coc.vim", """
function! coc#config(name, value) abort
  let g:test_coc_config[a:name] = a:value
endfunction
""")
    write(config / "colors" / "tokyonight.vim", 'let g:colors_name = "tokyonight"\n')
    project = Path(env["VIM_TEST_WORK"]) / "project with spaces"
    (project / ".git").mkdir(parents=True)
    write(project / "example.py", "value = missing_name\n")
    write(project / "example.go", "package main\n\nfunc main() {}\n")
    env["VIM_TEST_PROJECT"] = project.as_posix()


def run(editor, kind, script, env, label):
    flags = ["--headless"] if kind == "nvim" else ["-es", "-V1"]
    command = [editor, "-Nu", "NONE", "-i", "NONE", "-n", *flags,
               "-S", (ROOT / "scripts" / script).as_posix()]
    print(f"==> {kind}: {label}", flush=True)
    process_options = {"stdout": subprocess.PIPE, "stderr": subprocess.STDOUT}
    log = Path(env["VIM_TEST_WORK"]) / "editor.log"
    if os.name == "nt" and kind == "nvim":
        # Windows ConPTY inherits redirected parent stdio even with a new
        # pseudoconsole. Give Neovim a hidden console WITHOUT redirected handles;
        # otherwise :terminal output bypasses its buffer and goes to Python.
        # Vim's verbose log retains assertion/exception output on failure.
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = subprocess.SW_HIDE
        process_options = {"creationflags": subprocess.CREATE_NEW_CONSOLE,
                           "startupinfo": startup}
        log.unlink(missing_ok=True)
        command.insert(1, "-V1" + log.as_posix())
    result = subprocess.run(command, cwd=ROOT, env=env, text=True,
                            encoding="utf-8", errors="replace", timeout=60,
                            **process_options)
    if result.returncode:
        output = result.stdout if result.stdout is not None else (
            log.read_text(encoding="utf-8", errors="replace") if log.exists() else "")
        print(output, end="", flush=True)
        raise RuntimeError(f"{label} exited {result.returncode}")
    print(f"PASS: {label}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--editor", choices=("vim", "nvim"), required=True)
    parser.add_argument("--executable", help="Native path to the editor executable")
    parser.add_argument("--test", action="append", choices=("startup", "editor", "markdown", "modes"),
                        help="Run selected regressions only (repeatable)")
    args = parser.parse_args()
    editor = args.executable or shutil.which(args.editor)
    if not editor:
        parser.error(f"{args.editor} is not installed; use --executable")
    work = ROOT / (".editor-tests-" + uuid.uuid4().hex)
    try:
        env = environment(work)
        selected = args.test or ("startup", "editor", "markdown", "modes")
        for test in ("startup", "editor", "markdown"):
            if test not in selected:
                continue
            script = f"test-{test}.vim"
            run(editor, args.editor, script, env, script)
        modes = () if "modes" not in selected else (
            ("coc",) if args.editor == "vim" else (
            "coc", "cmp-efm", "cmp-builtin", "default"))
        if modes:
            mode_home(env)
        for mode in modes:
            env["NVIM_CONFIG"] = "" if mode == "default" else mode
            run(editor, args.editor, "test-modes.vim", env, f"mode {mode}")
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    finally:
        shutil.rmtree(work, ignore_errors=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
