"""Exercise the wrapper with a shell mock; no linters or packages are needed."""

import os
from pathlib import Path
import shutil
import subprocess
import unittest
import uuid


ROOT = Path(__file__).resolve().parents[1]
BASH = shutil.which("bash")


def bash_path(path):
    path = Path(path).resolve()
    if os.name == "nt":
        return "/" + path.drive[0].lower() + path.as_posix()[2:]
    return str(path)


class LinterWrapperTests(unittest.TestCase):
    def setUp(self):
        self.fixture = ROOT / (".linter-wrapper-test-" + uuid.uuid4().hex)
        self.project = self.fixture / "project with spaces"
        self.source = self.project / "src"
        self.source.mkdir(parents=True)
        self.document = self.source / "document with spaces.md"
        self.document.write_text("# Heading\n", encoding="utf-8")
        self.fallback = self.fixture / "fallback config.json"
        self.fallback.write_text("{}\n", encoding="utf-8")
        self.mock = self.fixture / "mock-linter"
        self.mock.write_text(
            '#!/usr/bin/env bash\nprintf "<%s>\\n" "$@"\n'
            'cat\nexit "${MOCK_STATUS:-0}"\n',
            encoding="utf-8",
            newline="\n",
        )
        self.mock.chmod(0o755)
        self.addCleanup(shutil.rmtree, self.fixture)

    def run_wrapper(self, args=(), prefix="", local=True, cwd=None,
                    status=0, filenames=".project-lint", options=None):
        if local:
            (self.project / ".project-lint").write_text("{}", encoding="utf-8")
        if options is None:
            options = [
                "--filenames=" + filenames,
                "--fallback-config=" + bash_path(self.fallback),
                "--config-flag=--config",
            ]
            if prefix is not None:
                options.append("--filename-arg-prefix=" + prefix)
        return subprocess.run(
            [BASH, bash_path(ROOT / "efm-langserver-linter-wrapper.sh"),
             *options, "--", bash_path(self.mock), *args],
            cwd=cwd or self.project,
            env={**os.environ, "MOCK_STATUS": str(status)},
            input="stdin is preserved\n",
            text=True,
            capture_output=True,
            timeout=15,
        )

    def assert_forwarded(self, result, args, status=0, fallback=False):
        self.assertEqual(result.returncode, status, result.stderr)
        expected = list(args)
        if fallback:
            expected[:0] = ["--config", bash_path(self.fallback)]
        self.assertEqual(
            result.stdout,
            "".join("<" + arg + ">\n" for arg in expected)
            + "stdin is preserved\n",
        )

    def test_markdown_positional_paths(self):
        for filename in (bash_path(self.document), "src/document with spaces.md",
                         str(self.document)):
            with self.subTest(filename=filename):
                args = ["--quiet", "--rule=value", filename]
                self.assert_forwarded(self.run_wrapper(args), args)

    def test_positional_separator_skips_option_values(self):
        args = ["--option", "not-a-filename", "--", bash_path(self.document)]
        self.assert_forwarded(self.run_wrapper(args), args)

    def test_eslint_flag_forms(self):
        filename = bash_path(self.document)
        for prefix, args in (
            ("--stdin-filename", ["--stdin", "--stdin-filename=" + filename]),
            ("--stdin-filename", ["--stdin", "--stdin-filename", filename]),
            ("--stdin-filename=", ["--stdin-filename=" + filename]),
            ("file:", ["file:" + filename]),
            ("-f", ["-f" + filename]),
        ):
            with self.subTest(prefix=prefix, args=args):
                self.assert_forwarded(self.run_wrapper(args, prefix=prefix), args)

    def test_relative_eslint_filename(self):
        for args in (["--stdin-filename=../src/document with spaces.md"],
                     ["--stdin-filename", "../src/document with spaces.md"]):
            with self.subTest(args=args):
                self.assert_forwarded(
                    self.run_wrapper(args, prefix="--stdin-filename",
                                     cwd=self.source), args)

    def test_project_wide_checks_current_directory(self):
        args = ["--verbose"]
        self.assert_forwarded(self.run_wrapper(args, prefix=None), args)

    def test_config_at_filesystem_root_is_checked(self):
        # A relative config name reaches our fixture only from the actual root.
        root_relative = bash_path(self.project / ".project-lint")
        if os.name == "nt":
            root_relative = root_relative[3:]
        else:
            root_relative = root_relative[1:]
        args = [bash_path(self.document)]
        self.assert_forwarded(
            self.run_wrapper(args, filenames=root_relative), args)

    def test_fallback_insertion_and_exit_status(self):
        args = [bash_path(self.document)]
        self.assert_forwarded(
            self.run_wrapper(args, local=False, status=17), args,
            status=17, fallback=True)

    def test_native_config_preserves_failure_and_needs_no_fallback(self):
        self.fallback.unlink()
        args = [bash_path(self.document)]
        self.assert_forwarded(
            self.run_wrapper(args, status=23), args, status=23)

    def test_missing_fallback(self):
        self.fallback.unlink()
        result = self.run_wrapper([bash_path(self.document)], local=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("fallback config file does not exist", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_missing_required_options(self):
        result = self.run_wrapper(options=[])
        self.assertEqual(result.returncode, 1)
        for option in ("--filenames", "--fallback-config", "--config-flag"):
            self.assertIn(option, result.stderr)
        self.assertEqual(result.stdout, "")

    def test_missing_command(self):
        result = subprocess.run(
            [BASH, bash_path(ROOT / "efm-langserver-linter-wrapper.sh"),
             "--filenames=.project-lint", "--fallback-config=unused",
             "--config-flag=--config", "--"],
            capture_output=True, text=True, timeout=15,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("Linter command is missing", result.stderr)

    def test_missing_or_ambiguous_filename(self):
        for prefix, args in (
            ("", []),
            ("", ["--quiet"]),
            ("", ["one.md", "two.md"]),
            ("--stdin-filename", ["--stdin-filename"]),
            ("--stdin-filename", ["--stdin-filename="]),
            ("--stdin-filename=", ["--stdin-filename=", "unrelated.md"]),
            ("file:", ["file:", "unrelated.md"]),
            ("--stdin-filename", ["--stdin-filename-extra=x.md"]),
            ("--stdin-filename", ["--stdin-filename=x.md",
                                  "--stdin-filename=y.md"]),
        ):
            with self.subTest(prefix=prefix, args=args):
                result = self.run_wrapper(args, prefix=prefix)
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn("[ERROR]", result.stderr)
                self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
