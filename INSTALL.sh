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

### Check for make
if ! [ -x "$(which make)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
      if ! [ -x "$(which mingw32-make)" ]; then
        echo "WARNING: \"make\" (or \"mingw32-make\") not found. Some plugins might not compile."
      fi
  else
      echo "ERROR: You must install \"make\" prior to installing."
      exit 1
  fi
fi

### Check for gcc
if ! [ -x "$(which gcc)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
      echo "WARNING: \"gcc\" not found. Some plugins might not compile."
  else
      echo "ERROR: You must install \"gcc\" prior to installing."
      exit 1
  fi
fi

### Check for curl
if ! [ -x "$(which curl)" ]; then
  echo "ERROR: You must install \"curl\" prior to installing."
  exit 1
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

### Check for node
if ! [ -x "$(which node)" ]; then
  if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]; then
    echo "WARNING: \"nodejs\" not found. coc-vim will not work."
  else
    echo "ERROR: You must install \"nodejs\" prior to installing due to coc-vim."
    exit 1
  fi
fi

### Install LSP servers/linters defined in lsp-servers.json (shared by both
### the coc and cmp/native-LSP flows -- see viml/coc-nvim.vim and
### viml/nvim-lsp-builtin.nvim). Best-effort: skipped with a warning if jq
### or the relevant package manager (pip/npm/go) isn't available.
if [ -x "$(which jq)" ]; then
  echo "Installing shared LSP servers from lsp-servers.json..."
  jq -r '.servers[] | select(.install) | "\(.name)\t\(.install)"' "$DIR/lsp-servers.json" |
  while IFS=$'\t' read -r NAME INSTALL_CMD; do
    BIN="$(echo "$INSTALL_CMD" | awk '{print $NF}')"
    if [ -x "$(which "$BIN" 2>/dev/null)" ] || [ -x "$(which "$NAME" 2>/dev/null)" ]; then
      echo "ALREADY INSTALLED: $NAME"
      continue
    fi
    MANAGER="$(echo "$INSTALL_CMD" | awk '{print $1}')"
    if ! [ -x "$(which "$MANAGER" 2>/dev/null)" ]; then
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

echo "INFO: Download vim-plug package manager to ~/.vim/autoload/plug.vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

# Install missing LSP servers / lint-format tools (metadata lives in
# lsp-servers.json and efm-langserver-config.yaml).
if command -v python3 >/dev/null 2>&1; then
  python3 "$DIR/scripts/install-lsp-tools.py" || WARN_MESSAGES+=("WARN: some LSP/lint tools failed to install; rerun scripts/install-lsp-tools.py")
fi

WARN_MESSAGES=()

WARN_MESSAGES+=("WARN: FOR VIM BE SURE TO INSTALL POWERLINE FONTS: sudo apt-get install fonts-powerline")

for MESSAGE in "${WARN_MESSAGES[@]}"; do
  echo -e "\033[0;33m$MESSAGE\033[0m"
done
