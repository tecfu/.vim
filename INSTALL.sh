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
  echo "ERROR: You must install \"make\" prior to installing."
  exit 1
fi

### Check for gcc
if ! [ -x "$(which gcc)" ]; then
  echo "ERROR: You must install \"gcc\" prior to installing."
  exit 1
fi

### Check for curl
if ! [ -x "$(which curl)" ]; then
  echo "ERROR: You must install \"curl\" prior to installing."
  exit 1
fi

### Check for node
if ! [ -x "$(which node)" ]; then
  echo "ERROR: You must install \"nodejs\" prior to installing due to coc-vim."
  exit 1
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

WARN_MESSAGES=()

WARN_MESSAGES+=("WARN: FOR VIM BE SURE TO INSTALL POWERLINE FONTS: sudo apt-get install fonts-powerline")

for MESSAGE in "${WARN_MESSAGES[@]}"; do
  echo -e "\033[0;33m$MESSAGE\033[0m"
done
