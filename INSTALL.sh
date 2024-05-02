#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS 
#   IN SOME OS
#   
#   ```
#    $ /bin/bash INSTALL.sh
#

### Check for make
if ! [ -x "$(which make)" ]; then
  echo "ERROR! You must install \"make\" prior to installing."
  exit 1
fi

### Check for gcc
if ! [ -x "$(which gcc)" ]; then
  echo "ERROR! You must install \"gcc\" prior to installing."
  exit 1
fi

### Check for curl
if ! [ -x "$(which curl)" ]; then
  echo "ERROR! You must install \"curl\" prior to installing."
  exit 1
fi

### Check for node
if ! [ -x "$(which node)" ]; then
  echo "ERROR! You must install \"nodejs\" prior to installing due to coc-vim."
  # echo "Attempting to install nodejs via nvm..."
  # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  # export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  exit 1
fi

# create nvim config directory they doesn't exist
mkdir -p $HOME/.config/nvim

cd $(dirname $0); __DIR__=$(pwd)
SYMLINKS=()
SYMLINKS+=("$__DIR__ $HOME/.vim")

if [[ "$__DIR__" != "$HOME/.vim" ]]; then
  for i in "${SYMLINKS[@]}"; do
    # split each command at the space to get config path
    IFS=" " read -ra OUT <<< "$i"
    echo "SYMLINKING: ln -s ${i}"
    if [ ! -d "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
      ln -s $i 
    
    elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
      mv "${OUT[1]}" "${OUT[1]}.saved"
      ln -s $i
    fi
  done
fi


### Configure Vim-Airline for Linux terminal

# Install Powerline Fonts
#git clone http://www.github.com/tecfu/fonts
#$__DIR__/fonts/install.sh # not working in ubuntu 20

# declare array
SYMLINKS=()
SYMLINKS+=("$__DIR__/.vimrc $HOME/.vimrc")
SYMLINKS+=("$__DIR__/init.vim $HOME/.config/nvim/init.vim")

#printf '%s\n' "${SYMLINKS[@]}"

for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  # ${OUT[1]} is path config file should be at
  
  #no config, create symlink to one
  if [ ! -f "${OUT[1]}" ] && [ ! -d "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
    echo "${OUT[1]} not found, creating configs..."
    ln -s $i 
  
  #config exsts; save if doesn't point to correct target
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    echo "MOVING ${OUT[1]} to ${OUT[1]}.saved"
    mv "${OUT[1]}" "${OUT[1]}.saved"
    ln -s $i
  fi
done

##### Disable capturing of Ctrl-S, Ctrl-Q in terminal mode:
#OBJECTIVE="Allow ctrl-s, ctrl-q in Vim"
#TARGETFILE1=$HOME"/.bashrc"
#SEARCHSTRING1="stty -ixon > /dev/null 2>/dev/null"
#if ! grep -Fxq "$SEARCHSTRING1" $TARGETFILE1;
#then 
#  #append code
#  echo $SEARCHSTRING1 >> $TARGETFILE1
#fi

echo "INFO: Download vim-plug package manager to ~/.vim/autoload/plug.vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

WARN_MESSAGES=()

WARN_MESSAGES+=("WARN: FOR VIM BE SURE TO INSTALL POWERLINE FONTS: sudo apt-get install fonts-powerline")
WARN_MESSAGES+=("WARN: FOR VIM BE SURE TO RUN :PlugInstall")

for MESSAGE in "${WARN_MESSAGES[@]}"; do
  echo -e "\033[0;33m$MESSAGE\033[0m"
done
