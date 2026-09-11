#!/bin/bash
# Run with bash, not sh.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
WINDOWS=0
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; esac
. "$DIR/scripts/install-status.sh"
INSTALL_FAILURES=()
INSTALL_GO_TOOLS=0
INSTALL_DOTNET_TOOLS=0

install_usage() {
  cat <<'EOF'
Usage: INSTALL.sh [--with-go] [--with-dotnet]

  --with-go       Install missing tools whose installer uses "go install".
  --with-dotnet   Install missing tools whose installer uses "dotnet tool install".
  -h, --help      Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-go) INSTALL_GO_TOOLS=1 ;;
    --with-dotnet) INSTALL_DOTNET_TOOLS=1 ;;
    -h|--help)
      install_usage
      return 0 2>/dev/null || exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      install_usage >&2
      return 2 2>/dev/null || exit 2
      ;;
  esac
  shift
done

# The surrounding dotfiles checkout supplies these helpers when available.
if [ -f "$DIR/../lib/common.sh" ]; then
  . "$DIR/../lib/common.sh"
else
  apt_install() {
    local ID=""
    [ -f /etc/os-release ] && . /etc/os-release
    [ "$ID" = ubuntu ] || return 1
    if [ "$(id -u)" = 0 ]; then
      apt-get update && apt-get install -y "$@"
    elif command -v sudo >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y "$@"
    else
      return 1
    fi
  }
  require_dep() {
    command -v "$1" >/dev/null 2>&1 && return 0
    apt_install "$2" && command -v "$1" >/dev/null 2>&1 && return 0
    echo "WARNING: \"$1\" not found; install package \"$2\" to enable this feature."
    return 1
  }
  install_skip() { echo "WARNING: $*"; }
fi

if [ "$WINDOWS" = 1 ]; then
  if ! command -v make >/dev/null 2>&1 && ! command -v mingw32-make >/dev/null 2>&1; then
    echo 'WARNING: "make" (or "mingw32-make") not found. Some plugins might not compile.'
  fi
  command -v gcc >/dev/null 2>&1 || echo 'WARNING: "gcc" not found. Some plugins might not compile.'
else
  require_dep make build-essential || true
  require_dep gcc build-essential || true
fi
install_step "curl dependency" require_dep curl curl
if ! command -v nvim >/dev/null 2>&1; then
  install_step "Vim dependency" require_dep vim vim
fi
[ "$WINDOWS" = 1 ] || require_dep xsel xsel || true
require_dep node nodejs || true

# PEP 668 blocks pip install --user on modern Debian/Ubuntu.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v pipx >/dev/null 2>&1; then
  apt_install pipx || echo "WARNING: pipx unavailable; Python CLI tools need pipx (not system pip)."
  if command -v pipx >/dev/null 2>&1; then
    pipx ensurepath >/dev/null 2>&1 || true
  fi
fi

. "$DIR/scripts/config-links.sh"
config_paths
install_step "configuration directories" mkdir -p "$NVIM_CONFIG_DIR" "$EFM_CONFIG"
install_step "repository link" link_config "$DIR" "$HOME/.vim"
install_step "Vim configuration link" link_config "$DIR/.vimrc" "$HOME/.vimrc"
install_step "Neovim configuration link" link_config "$DIR/init.vim" "$NVIM_CONFIG_DIR/init.vim"
install_step "EFM configuration link" link_config "$DIR/efm-langserver-config.yaml" "$EFM_CONFIG/config.yaml"
install_step "EFM wrapper link" link_config "$DIR/efm-langserver-linter-wrapper.sh" "$EFM_CONFIG/efm-langserver-linter-wrapper.sh"

if command -v curl >/dev/null 2>&1; then
  echo "INFO: Download vim-plug package manager to ~/.vim/autoload/plug.vim"
  if install_step "vim-plug download" curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    if command -v nvim >/dev/null 2>&1; then
      install_step "Neovim plugins" install_plugins nvim "$DIR/scripts/install-plugins.vim" "$DIR/.install-plugins.log"
    elif command -v vim >/dev/null 2>&1; then
      install_step "Vim plugins" install_plugins vim "$DIR/scripts/install-plugins.vim" "$DIR/.install-plugins.log"
    fi
  fi
else
  install_skip "curl missing; skipping vim-plug download and plugin install"
fi

WARN_MESSAGES=()
PY=""
# Windows can expose a python3 Store alias that exists but cannot run.
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; sys.exit(sys.version_info.major != 3)' >/dev/null 2>&1; then
    PY="$candidate"
    break
  fi
done
if [ -n "$PY" ]; then
  TOOL_ARGS=()
  [ "$INSTALL_GO_TOOLS" = 1 ] && TOOL_ARGS+=(--with-go)
  [ "$INSTALL_DOTNET_TOOLS" = 1 ] && TOOL_ARGS+=(--with-dotnet)
  install_step "LSP/lint tools" "$PY" "$DIR/scripts/install-lsp-tools.py" "${TOOL_ARGS[@]}"
else
  WARN_MESSAGES+=("WARN: Python 3 (python3/python) not found; skipped LSP/lint auto-install")
fi
apt_install fonts-powerline || WARN_MESSAGES+=("WARN: Install Powerline fonts manually for Vim.")
for MESSAGE in "${WARN_MESSAGES[@]}"; do
  printf '\033[0;33m%s\033[0m\n' "$MESSAGE"
done
install_summary
