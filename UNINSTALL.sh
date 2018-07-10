#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS 
#   IN SOME OS
#   
#   ```
#    $ /bin/bash UNINSTALL.sh
#
###



# declare array
SYMLINKS=()
SYMLINKS+=("$HOME/dotfiles/.vim $HOME/.vim")
SYMLINKS+=("$HOME/dotfiles/.vim/.vimrc $HOME/.vimrc")

for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  #${OUT[1]} is path config file should be at
  
  #nothing to do
  if [ ! -f "${OUT[1]}" ] && [ ! -d "${OUT[1]}" ]; then
    echo "CONFIG FILES ALREADY REMOVED" 
  #restore old configs
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    echo "REMOVING ${OUT[1]}.saved"
    mv "${OUT[1]}.saved" "${OUT[1]}"
  fi
done

#### Disable capturing of Ctrl-S, Ctrl-Q in terminal mode:
TARGETFILE1=$HOME"/.bashrc"
SEARCHSTRING1="stty -ixon > /dev/null 2>/dev/null"

if [ grep -Fxq "$SEARCHSTRING1" $TARGETFILE1 ];
then 
  #remove code from file
  sed -i '/$SEARCHSTRING1/d' $TARGETFILE1
fi

printf "\n"
echo DONE.

