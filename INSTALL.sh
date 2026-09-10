#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS
#   IN SOME OS
#
#   ```
#    $ /bin/bash INSTALL.sh
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

. "$DIR/../lib/common.sh"
### Check build tools (make, gcc): auto-install on Ubuntu; warn-only on Windows
if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
    if ! [ -x "$(which make)" ] && ! [ -x "$(which mingw32-make)" ]; then
        echo "WARNING: \"make\" (or \"mingw32-make\") not found. Some plugins might not compile."
    fi
    if ! [ -x "$(which gcc)" ]; then
        echo "WARNING: \"gcc\" not found. Some plugins might not compile."
    fi
else
    require_dep make build-essential || true
    require_dep gcc build-essential || true
fi

### curl (needed for vim-plug download; guarded below)
require_dep curl curl || true

### vim (plugin-install fallback when nvim is absent)
require_dep vim vim || true

### xsel: clipboard support (preferred over clipman)
require_dep xsel xsel || true

### node (needed by coc; its config symlink is dep-gated below)
HAVE_NODE=1
if ! require_dep node nodejs; then
    HAVE_NODE=0
fi

### Check for make
if ! [ -x "$(which make)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
      if ! [ -x "$(which mingw32-make)" ]; then
        echo "WARNING: \"make\" (or \"mingw32-make\") not found. Some plugins might not compile."
      fi
  else
      require_dep make "sudo apt-get install build-essential" || true
  fi
fi

### Check for gcc
if ! [ -x "$(which gcc)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
      echo "WARNING: \"gcc\" not found. Some plugins might not compile."
  else
      require_dep gcc "sudo apt-get install build-essential" || true
  fi
fi

### Check for curl (needed for vim-plug download; guarded below)
if ! [ -x "$(which curl)" ]; then
  require_dep curl "sudo apt-get install curl" || true
fi

### Check for xsel on Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" == "ubuntu" ]; then
        if ! [ -x "$(which xsel)" ]; then
            echo "Installing xsel for clipboard support (preferred over clipman)..."
            sudo apt-get update && sudo apt-get install -y xsel
        fi
    fi
fi

### Check for node (needed by coc; its config symlink is dep-gated below)
HAVE_NODE=1
if ! [ -x "$(which node)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
    echo "WARNING: \"nodejs\" not found. coc-vim will not work."
    HAVE_NODE=0
  else
    require_dep node "sudo apt-get install nodejs" || HAVE_NODE=0
  fi
fi

### Ensure pipx is available for Python CLI tools (basedpyright, ruff, black, …).
### PEP 668 blocks plain `pip install --user` on modern Debian/Ubuntu.
if ! command -v pipx >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    echo "INFO: installing pipx (required for Python LSP tools under PEP 668)..."
    apt_install pipx || true
    export PATH="$HOME/.local/bin:$PATH"
    if command -v pipx >/dev/null 2>&1; then
      pipx ensurepath >/dev/null 2>&1 || true
    fi
  else
    echo "WARNING: pipx not found and apt-get unavailable; Python LSP tools may fail to install."
  fi
else
  export PATH="$HOME/.local/bin:$PATH"
fi

### Install LSP servers/linters defined in lsp-servers.json (shared by both
### the coc and cmp/native-LSP flows -- see viml/coc-nvim.vim and
### viml/nvim-lsp-builtin.nvim). Best-effort: skipped with a warning if jq
### or the relevant package manager (pipx/npm/go) isn't available.
if [ -x "$(which jq)" ]; then
  echo "Installing shared LSP servers from lsp-servers.json..."
  jq -r '.servers[] | select(.install) | "\(.name)\t\(.install)"' "$DIR/lsp-servers.json" |
  while IFS=$'\t' read -r NAME INSTALL_CMD; do
    BIN="$(echo "$INSTALL_CMD" | awk '{print $NF}')"
    if command -v "$BIN" >/dev/null 2>&1 || command -v "$NAME" >/dev/null 2>&1; then
      echo "ALREADY INSTALLED: $NAME"
      continue
    fi
    MANAGER="$(echo "$INSTALL_CMD" | awk '{print $1}')"
    if ! command -v "$MANAGER" >/dev/null 2>&1; then
      echo "WARNING: \"$MANAGER\" not found. Skipping install of $NAME ($INSTALL_CMD)."
      continue
    fi
    echo "INSTALLING: $NAME ($INSTALL_CMD)"
    eval "$INSTALL_CMD" || echo "WARNING: Failed to install $NAME."
  done
else
  echo "WARNING: \"jq\" not found. Skipping auto-install of servers listed in lsp-servers.json."
fi
# --- Create required config directories if they don't exist ---
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/efm-langserver"

SYMLINKS=()
SYMLINKS+=("$DIR $HOME/.vim")
# coc needs node; skip its config when node is missing and --ignore-missing-deps is set
[ "$HAVE_NODE" = 1 ] && SYMLINKS+=("$DIR/coc-settings.json $HOME/.config/nvim/coc-settings.json")

if [[ "$DIR" != "$HOME/.vim" ]]; then
  for i in "${SYMLINKS[@]}"; do
    # split each command at the space to get config path
    IFS=" " read -ra OUT <<< "$i"
    echo "SYMLINKING: ln -s ${i}"
    if [ ! -d "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
      ln -s "$i"

    elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
      mv "${OUT[1]}" "${OUT[1]}.saved"
      ln -s "$i"
    fi
  done
fi


### Configure Vim-Airline for Linux terminal

# Install Powerline Fonts
#git clone http://www.github.com/tecfu/fonts
#$DIR/fonts/install.sh # not working in ubuntu 20

# declare array for file symlinks
SYMLINKS=()
SYMLINKS+=("$DIR/.vimrc $HOME/.vimrc")
SYMLINKS+=("$DIR/init.vim $HOME/.config/nvim/init.vim")
SYMLINKS+=("$DIR/coc-settings.json $HOME/.config/nvim/coc-settings.json")
# --- ADDED EFM-LANGSERVER CONFIG AND WRAPPER SCRIPT ---
SYMLINKS+=("$DIR/efm-langserver-config.yaml $HOME/.config/efm-langserver/config.yaml")
SYMLINKS+=("$DIR/efm-langserver-linter-wrapper.sh $HOME/.config/efm-langserver/efm-langserver-linter-wrapper.sh")

for i in "${SYMLINKS[@]}"; do
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  SOURCE="${OUT[0]}"
  TARGET="${OUT[1]}"

  #no config, create symlink to one
  if [ ! -f "$TARGET" ] && [ ! -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
    echo "SYMLINKING: ln -s $SOURCE $TARGET"
    ln -s "$SOURCE" "$TARGET"

  #config exists; save if it doesn't point to our target
  elif [ -L "$TARGET" ] && [ "$(readlink -- "$TARGET")" != "$SOURCE" ]; then
    echo "UPDATING SYMLINK: Backing up existing link at $TARGET to $TARGET.saved"
    mv "$TARGET" "$TARGET.saved"
    echo "SYMLINKING: ln -s $SOURCE $TARGET"
    ln -s "$SOURCE" "$TARGET"
  elif [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
    echo "MOVING EXISTING FILE: $TARGET to $TARGET.saved"
    mv "$TARGET" "$TARGET.saved"
    echo "SYMLINKING: ln -s $SOURCE $TARGET"
    ln -s "$SOURCE" "$TARGET"
  else
    echo "ALREADY SYMLINKED: $TARGET -> $SOURCE"
  fi
done

if command -v curl >/dev/null 2>&1; then
  echo "INFO: Download vim-plug package manager to ~/.vim/autoload/plug.vim"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # Avoid E558 terminfo errors (e.g. TERM=alacritty without a matching entry)
  # and the resulting "Press ENTER" pause when running non-interactively.
  # Prefer nvim --headless when available; otherwise force a safe TERM.
  if command -v nvim >/dev/null 2>&1; then
    nvim --headless +PlugInstall +qall 2>/dev/null || true
  else
    TERM=ansi vim -c 'set nomore' -c 'PlugInstall' -c 'qa!' 2>/dev/null || \
      TERM=xterm-256color vim -c 'set nomore' -c 'PlugInstall' -c 'qa!' || true
  fi
else
  install_skip "curl missing; skipping vim-plug download and plugin install"
fi

WARN_MESSAGES=()

# Install missing LSP servers / lint-format tools (metadata lives in
# lsp-servers.json and efm-langserver-config.yaml).
if command -v python3 >/dev/null 2>&1; then
  python3 "$DIR/scripts/install-lsp-tools.py" || WARN_MESSAGES+=("WARN: some LSP/lint tools failed to install; rerun scripts/install-lsp-tools.py")
else
  WARN_MESSAGES+=("WARN: python3 not found; skipped scripts/install-lsp-tools.py (LSP/lint auto-install)")
fi

apt_install fonts-powerline || WARN_MESSAGES+=("WARN: FOR VIM BE SURE TO INSTALL POWERLINE FONTS: sudo apt-get install fonts-powerline")

for MESSAGE in "${WARN_MESSAGES[@]}"; do
  echo -e "\033[0;33m$MESSAGE\033[0m"
done
