import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent


@unittest.skipUnless(shutil.which("bash"), "bash is required")
class InstallStatusTests(unittest.TestCase):
    def run_shell(self, body):
        with tempfile.TemporaryDirectory(prefix=".status-test-", dir=ROOT) as work:
            env = os.environ.copy()
            env.pop("BASH_ENV", None)
            env.update(TEST_WORK=work, TEST_HELPER=str(ROOT / "scripts" / "install-status.sh"))
            result = subprocess.run(
                [shutil.which("bash"), "--noprofile", "--norc", "-s"],
                input='cd "$TEST_WORK" || exit 1\n. "$TEST_HELPER"\nINSTALL_FAILURES=()\n' + body,
                env=env, text=True, capture_output=True,
            )
        return result

    def test_failures_accumulate_and_summary_fails(self):
        result = self.run_shell('''
        install_step "first operation" bash -c 'exit 7'
        install_step "second operation" false
        install_step "successful operation" true
        install_summary
        ''')
        self.assertEqual(result.returncode, 1)
        self.assertIn("first operation (exit 7)", result.stderr)
        self.assertIn("second operation (exit 1)", result.stderr)
        self.assertNotIn("successful operation", result.stderr)
        self.assertNotIn("Installation completed", result.stdout)

    def test_optional_warning_does_not_fail_summary(self):
        result = self.run_shell('''
        echo "WARNING: optional build tool unavailable"
        install_step "successful operation" true
        install_summary
        ''')
        self.assertEqual(result.returncode, 0)
        self.assertIn("Installation completed", result.stdout)

    def test_plugin_failure_keeps_log_and_surfaces_output(self):
        result = self.run_shell('''
        nvim() { printf 'editor failure detail\\n' >&2; return 9; }
        install_step "plugins" install_plugins nvim fake.vim "$PWD/plugins.log"
        test -s "$PWD/plugins.log" || exit 99
        install_summary
        ''')
        self.assertEqual(result.returncode, 1)
        self.assertIn("editor failure detail", result.stderr)
        self.assertIn("plugins (exit 9)", result.stderr)

    def test_plugin_success_uses_script_and_reports_log(self):
        result = self.run_shell('''
        nvim() { printf '%s\\n' "$@"; }
        install_step "plugins" install_plugins nvim fake.vim "$PWD/plugins.log"
        grep -- '--headless' "$PWD/plugins.log" || exit 99
        grep -- 'fake.vim' "$PWD/plugins.log" || exit 99
        install_summary
        ''')
        self.assertEqual(result.returncode, 0)
        self.assertIn("Plugin installation completed", result.stdout)

    def test_vim_uses_ex_mode_without_suppressing_errors(self):
        result = self.run_shell('''
        vim() { printf '%s\\n' "$@"; }
        install_plugins vim fake.vim "$PWD/plugins.log"
        grep -- '-es' "$PWD/plugins.log"
        ''')
        self.assertEqual(result.returncode, 0)

    @unittest.skipUnless(shutil.which("vim"), "Vim is required")
    def test_vim_plug_report_controls_exit_status(self):
        for failed, startup_error in ((False, False), (True, False), (False, True)):
            with self.subTest(failed=failed, startup_error=startup_error), tempfile.TemporaryDirectory(
                    prefix=".plugin-report-", dir=ROOT) as work:
                driver = Path(work) / "driver.vim"
                driver.write_text(
                    "set nocompatible\n"
                    + ("call MissingConfigurationFunction()\n" if startup_error else "")
                    +
                    "function! FixtureReport()\n"
                    "  enew\n"
                    "  file [Plugins]\n"
                    "  call setline(1, " + repr("x fixture: failed" if failed else "- Done!") + ")\n"
                    "endfunction\n"
                    "command! -nargs=* PlugInstall call FixtureReport()\n"
                    "execute 'source' fnameescape($TEST_INSTALL_SCRIPT)\n",
                    encoding="utf-8",
                )
                env = os.environ.copy()
                env.pop("BASH_ENV", None)
                env.update(TEST_DRIVER=str(driver),
                           TEST_INSTALL_SCRIPT=str(ROOT / "scripts" / "install-plugins.vim"))
                result = subprocess.run(
                    [shutil.which("bash"), "--noprofile", "--norc", "-s"],
                    input='''if command -v cygpath >/dev/null 2>&1; then
                        TEST_DRIVER="$(cygpath -u "$TEST_DRIVER")"
                        export TEST_INSTALL_SCRIPT="$(cygpath -u "$TEST_INSTALL_SCRIPT")"
                    fi
                    vim -Nu NONE -i NONE -n -es -V1 -S "$TEST_DRIVER"
                    ''',
                    env=env, text=True, capture_output=True, timeout=30,
                )
                if failed or startup_error:
                    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                else:
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                if startup_error:
                    self.assertIn("Configuration failed before plugin installation", result.stderr)


if __name__ == "__main__":
    unittest.main()
