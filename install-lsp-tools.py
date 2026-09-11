#!/usr/bin/env python3
"""Compatibility entry point; implementation lives in scripts/."""
from pathlib import Path
import runpy

if __name__ == "__main__":
    runpy.run_path(str(Path(__file__).resolve().parent / "scripts" / "install-lsp-tools.py"),
                   run_name="__main__")
