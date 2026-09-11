"""Focused installer regressions: python -m unittest discover -s scripts -p test_*.py."""
from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import unittest
from unittest.mock import Mock, patch
import uuid

ROOT = Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location("install_lsp_tools", ROOT / "scripts" / "install-lsp-tools.py")
INSTALLER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(INSTALLER)


class WorkspaceTest(unittest.TestCase):
    def setUp(self):
        # Keep scratch files in the checkout, never in the system temp directory.
        self.work = ROOT / (".installer-test-" + uuid.uuid4().hex)
        self.work.mkdir()
        self.addCleanup(shutil.rmtree, self.work)

    def write(self, name, text):
        path = self.work / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path


class ToolInstallerTests(WorkspaceTest):
    def profile(self, servers):
        self.write("coc-profiles/default/coc-settings.json",
                   json.dumps({"languageserver": servers}))

    def invoke(self, dry_run=False, present=(), root=None):
        output = io.StringIO()
        with patch.object(INSTALLER.shutil, "which",
                          side_effect=lambda binary: binary if binary in present else None), \
                patch.object(INSTALLER.subprocess, "run", return_value=Mock(returncode=0)) as run, \
                redirect_stdout(output), redirect_stderr(output):
            code = INSTALLER.main(["--dry-run"] if dry_run else [],
                                  root=self.work if root is None else root)
        return code, output.getvalue(), run

    def test_repo_metadata_uses_required_efm_fork(self):
        code, _, run = self.invoke(root=ROOT)
        self.assertEqual(code, 0)
        commands = [call.args[0] for call in run.call_args_list]
        self.assertEqual(commands.count("go install github.com/tecfu/efm-langserver@latest"), 1)
        self.assertFalse(any("github.com/mattn/efm-langserver" in cmd for cmd in commands))

    def test_repo_installs_prettierd_even_when_efm_is_present(self):
        code, _, run = self.invoke(root=ROOT, present={"efm-langserver"})
        self.assertEqual(code, 0)
        commands = [call.args[0] for call in run.call_args_list]
        self.assertIn("npm install -g @fsouza/prettierd", commands)
        self.assertFalse(any("go install github.com/tecfu/efm-langserver" in cmd for cmd in commands))

    def test_jsonc_preserves_strings_and_ignores_sample_servers(self):
        path = self.write("settings.json", r'''
        {
          // "sample": {"command": "do-not-install"},
          /* a block comment */
          "url": "https://example.com/a/*b*/,}",
          "escaped": "quote: \" // still a string",
          "array": [1, /* trailing */],
        }''')
        data = INSTALLER.load_jsonc(path)
        self.assertEqual(data["url"], "https://example.com/a/*b*/,}")
        self.assertEqual(data["escaped"], 'quote: " // still a string')
        self.assertEqual(data["array"], [1])
        self.assertNotIn("sample", data)

    def test_profile_detection_uses_command_not_package(self):
        self.profile({"json": {"command": "vscode-json-language-server",
                               "sources": ["npm i -g vscode-langservers-extracted"]}})
        code, _, run = self.invoke(present={"vscode-json-language-server"})
        self.assertEqual(code, 0)
        run.assert_not_called()
        code, _, run = self.invoke(present={"vscode-langservers-extracted"})
        self.assertEqual(code, 0)
        run.assert_called_once_with("npm i -g vscode-langservers-extracted", shell=True)

    def test_shared_and_profile_install_commands_are_deduplicated(self):
        self.write("lsp-servers.json", json.dumps({"servers": [
            {"name": "python", "cmd": ["basedpyright-langserver", "--stdio"],
             "install": "pipx install basedpyright"},
            {"name": "json", "cmd": ["vscode-json-language-server"],
             "install": "npm install -g vscode-langservers-extracted"}
        ]}))
        self.profile({
            "python": {"command": "basedpyright-langserver",
                       "sources": ["pipx install basedpyright"]},
            "json": {"command": "vscode-json-language-server",
                     "sources": ["npm i -g vscode-langservers-extracted"]},
        })
        code, _, run = self.invoke()
        self.assertEqual(code, 0)
        self.assertEqual(run.call_count, 2)

    def test_dry_run_never_runs_checks_or_installs(self):
        self.write("efm-langserver-config.yaml", "ignored by mock")
        metadata = {"tools": {
            "black": {"checkInstalled": "which black", "install": "pipx install black"},
            "unsafe": {"checkInstalled": "pipx install unwanted",
                       "install": "pipx install unsafe"},
        }}
        self.profile({"python": {"command": "basedpyright-langserver",
                                 "sources": ["pipx install basedpyright"]}})
        with patch.object(INSTALLER, "yaml", Mock(safe_load=Mock(return_value=metadata))):
            code, output, run = self.invoke(dry_run=True)
        self.assertEqual(code, 0)
        run.assert_not_called()
        self.assertIn("Would install 'black'", output)
        self.assertIn("Would install 'default:python'", output)
        self.assertNotIn("Installing '", output)

    def test_missing_yaml_does_not_skip_shared_or_profile_tools(self):
        self.write("efm-langserver-config.yaml", "tools: {}")
        self.write("lsp-servers.json", json.dumps({"servers": [
            {"name": "ruff", "cmd": ["ruff", "server"], "install": "pipx install ruff"}
        ]}))
        self.profile({"json": {"command": "json-server", "sources": ["npm install -g json-server"]}})
        with patch.object(INSTALLER, "yaml", None):
            code, output, run = self.invoke()
        self.assertEqual(code, 0)
        self.assertIn("PyYAML unavailable", output)
        self.assertEqual(run.call_count, 2)

    def test_manual_disabled_and_commented_sources_are_not_installed(self):
        self.write("coc-profiles/default/coc-settings.json", '''
        {"languageserver": {
          // "sample": {"command": "fake", "sources": ["npm install fake"]},
          "disabled": {"disabled": true, "command": "fake", "sources": ["npm install fake"]},
          "manual": {"command": "terraform-ls", "sources": ["https://example.com/tool"]},
        }}''')
        code, output, run = self.invoke()
        self.assertEqual(code, 0)
        self.assertIn("no runnable install source", output)
        run.assert_not_called()

    def test_auxiliary_tool_uses_shared_binary_check(self):
        self.write("efm-langserver-config.yaml", "ignored by mock")
        metadata = {"tools": {"eslint": {
            "checkInstalled": "which eslint_d", "install": "npm install -g eslint_d"}}}
        self.profile({"efm": {"command": "efm-langserver", "sources": [
            "go install github.com/mattn/efm-langserver@latest", "npm install -g eslint_d"]}})
        with patch.object(INSTALLER, "yaml", Mock(safe_load=Mock(return_value=metadata))):
            code, _, run = self.invoke(present={"eslint_d"})
        self.assertEqual(code, 0)
        run.assert_called_once_with("go install github.com/mattn/efm-langserver@latest", shell=True)

    def test_explicit_home_path_and_portable_checks(self):
        with patch.dict(os.environ, {"HOME": str(self.work)}):
            self.assertEqual(INSTALLER.expand_binary("$HOME/go/bin/efm"), str(self.work) + "/go/bin/efm")
        for check in ("which black", "where black", "command -v black"):
            self.assertEqual(INSTALLER.check_binary(check), "black")
        self.assertIsNone(INSTALLER.check_binary("which black || pipx install black"))

    def test_install_failure_returns_nonzero(self):
        self.profile({"python": {"command": "missing", "sources": ["pipx install missing"]}})
        with patch.object(INSTALLER.shutil, "which", return_value=None), \
                patch.object(INSTALLER.subprocess, "run", return_value=Mock(returncode=1)), \
                redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            self.assertEqual(INSTALLER.main([], root=self.work), 1)

    def test_invalid_metadata_fails_before_any_install(self):
        self.write("lsp-servers.json", '{"servers": [')
        code, output, run = self.invoke()
        self.assertEqual(code, 1)
        self.assertIn("Cannot read install metadata", output)
        run.assert_not_called()

    def test_yaml_errors_include_file_context(self):
        self.write("efm-langserver-config.yaml", "tools: [")
        class YAMLError(ValueError):
            pass
        parser = Mock(YAMLError=YAMLError, safe_load=Mock(side_effect=YAMLError("bad YAML")))
        with patch.object(INSTALLER, "yaml", parser):
            code, output, run = self.invoke()
        self.assertEqual(code, 1)
        self.assertIn("efm-langserver-config.yaml: bad YAML", output)
        run.assert_not_called()

    def test_install_oserror_includes_failure_details(self):
        self.profile({"python": {"command": "missing", "sources": ["pipx install missing"]}})
        output = io.StringIO()
        with patch.object(INSTALLER.shutil, "which", return_value=None), \
                patch.object(INSTALLER.subprocess, "run", side_effect=OSError("permission denied")), \
                redirect_stdout(output), redirect_stderr(output):
            self.assertEqual(INSTALLER.main([], root=self.work), 1)
        self.assertIn("install failed for 'default:python': permission denied", output.getvalue())


@unittest.skipUnless(shutil.which("bash"), "bash is unavailable")
class ShellInstallerTests(WorkspaceTest):
    def bash(self, body, variables=None):
        functions = (ROOT / "scripts" / "config-links.sh").read_text(encoding="utf-8")
        env = os.environ.copy()
        env.update({"WINDOWS": "0", "HOME": str(self.work), "XDG_CONFIG_HOME": ""})
        env.update(variables or {})
        env.pop("BASH_ENV", None)
        env["TEST_WORK"] = str(self.work)
        result = subprocess.run(
            [shutil.which("bash"), "--noprofile", "--norc", "-s"],
            input='cd "$TEST_WORK" || exit 1\n' + functions + "\n" + body,
            env=env, cwd=ROOT, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def test_spaces_and_existing_backups_are_preserved(self):
        output = self.bash('''
        printf source > "source file"
        printf old > "target file"
        printf backup > "target file.saved"
        link_config "$PWD/source file" "$PWD/target file"
        test "$(cat "target file")" = source || exit 1
        test "$(cat "target file.saved")" = backup || exit 1
        test "$(cat "target file.saved.1")" = old || exit 1
        ''')
        self.assertIn("BACKING UP", output)

    def test_unmanaged_directory_is_not_reported_as_link(self):
        output = self.bash('''
        mkdir source target
        link_config "$PWD/source" "$PWD/target" && exit 1
        test -d target
        ''')
        self.assertIn("unmanaged directory left untouched", output)
        self.assertNotIn("ALREADY SYMLINKED", output)

    def test_copy_fallback_is_reported(self):
        output = self.bash('''
        ln() { cp -- "$3" "$4"; }
        printf source > source
        link_config "$PWD/source" "$PWD/target"
        ''')
        self.assertIn("plain copy, not a symlink", output)

    def test_native_windows_and_xdg_config_paths(self):
        output = self.bash('''
        WINDOWS=1
        export NVIM_CONFIG=coc
        LOCALAPPDATA="$PWD/Local AppData"
        unset XDG_CONFIG_HOME
        config_paths
        test "$NVIM_CONFIG_DIR" = "$LOCALAPPDATA/nvim" || exit 1
        XDG_CONFIG_HOME="$PWD/Custom Config"
        config_paths
        test "$NVIM_CONFIG_DIR" = "$XDG_CONFIG_HOME/nvim" || exit 1
        test "$EFM_CONFIG" = "$XDG_CONFIG_HOME/efm-langserver" || exit 1
        test "$NVIM_CONFIG" = coc || exit 1
        bash -c 'test "$NVIM_CONFIG" = coc' || exit 1
        echo paths-ok
        ''')
        self.assertIn("paths-ok", output)

    def test_installer_does_not_link_nonexistent_root_coc_settings(self):
        script = (ROOT / "INSTALL.sh").read_text(encoding="utf-8")
        self.assertNotIn('link_config "$DIR/coc-settings.json"', script)
        self.assertNotIn("setx", script)

    def test_backup_numbers_increase_even_with_gaps(self):
        self.bash('''
        printf source > "source file"
        printf old > "target file"
        printf backup > "target file.saved.9"
        link_config "$PWD/source file" "$PWD/target file"
        test "$(cat "target file.saved.10")" = old || exit 1
        test "$(cat "target file.saved.9")" = backup || exit 1
        test "$(latest_config_backup "$PWD/target file")" = "$PWD/target file.saved.10"
        ''')

    def test_unlink_preserves_unmanaged_files_directories_and_backups(self):
        output = self.bash('''
        printf source > source
        printf unmanaged > target
        printf backup > target.saved.1
        mkdir directory
        unlink_config "$PWD/source" "$PWD/target"
        unlink_config "$PWD/source" "$PWD/directory"
        test "$(cat target)" = unmanaged || exit 1
        test "$(cat target.saved.1)" = backup || exit 1
        test -d directory
        ''')
        self.assertEqual(output.count("SKIPPING:"), 2)
        self.assertNotIn("RESTORING", output)

    def test_unlink_restores_latest_backup_only_for_matching_link(self):
        # Model link metadata to exercise removal even on Windows accounts
        # where ln silently creates copies rather than real symlinks.
        output = self.bash('''
        printf source > "source file"
        printf link > "target file"
        printf oldest > "target file.saved"
        printf older > "target file.saved.2"
        printf newest > "target file.saved.10"
        function [ {
          if builtin [ "$1" = ! ]; then
            shift
            ! [ "$@"
          elif builtin [ "$1" = -L ] && builtin [ "$2" = "$PWD/target file" ]; then
            builtin [ -f "$2" ]
          else
            builtin [ "$@"
          fi
        }
        readlink() { printf '%s' "$PWD/source file"; }
        unlink_config "$PWD/not our source" "$PWD/target file"
        test "$(cat "target file")" = link || exit 1
        unlink_config "$PWD/source file" "$PWD/target file"
        test "$(cat "target file")" = newest || exit 1
        test "$(cat "target file.saved.2")" = older || exit 1
        test "$(cat "target file.saved")" = oldest || exit 1
        test ! -e "target file.saved.10"
        ''')
        self.assertIn("SKIPPING:", output)
        self.assertIn("RESTORING BACKUP:", output)

    def test_uninstall_uses_shared_paths_and_matching_link_helper(self):
        script = (ROOT / "UNINSTALL.sh").read_text(encoding="utf-8")
        self.assertIn('. "$DIR/scripts/config-links.sh"\nconfig_paths', script)
        self.assertIn('unlink_config "$DIR/init.vim" "$NVIM_CONFIG_DIR/init.vim"', script)
        self.assertIn('unlink_config "$DIR/efm-langserver-config.yaml" "$EFM_CONFIG/config.yaml"', script)
        self.assertNotIn("IFS=", script)


if __name__ == "__main__":
    unittest.main()
