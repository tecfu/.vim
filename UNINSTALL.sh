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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# declare array of symlinks to be removed
SYMLINKS=()
SYMLINKS+=("$DIR $HOME/.vim")
SYMLINKS+=("$DIR/.vimrc $HOME/.vimrc")
SYMLINKS+=("$DIR/init.vim $HOME/.config/nvim/init.vim")
SYMLINKS+=("$DIR/coc-settings.json $HOME/.config/nvim/coc-settings.json")
# --- ADDED EFM-LANGSERVER CONFIG AND WRAPPER SCRIPT ---
SYMLINKS+=("$DIR/efm-langserver-config.yaml $HOME/.config/efm-langserver/config.yaml")
SYMLINKS+=("$DIR/efm-langserver-linter-wrapper.sh $HOME/.config/efm-langserver/efm-langserver-linter-wrapper.sh")

for i in "${SYMLINKS[@]}"; do
  IFS=' ' read -ra OUT <<< "$i"
  SOURCE="${OUT[0]}"
  TARGET="${OUT[1]}"

  # Check if the target is a symlink and points to our source file/dir
  if [ -L "$TARGET" ] && [ "$(readlink -- "$TARGET")" == "$SOURCE" ]; then
    echo "REMOVING SYMLINK: $TARGET"
    rm "$TARGET"

    # If a backup exists from the installation, restore it
    if [ -e "$TARGET.saved" ]; then
      echo "RESTORING BACKUP: $TARGET.saved -> $TARGET"
      mv "$TARGET.saved" "$TARGET"
    fi
  else
    echo "SKIPPING: $TARGET is not a symlink managed by this script."
  fi
done

# Clean up the efm-langserver directory if it's now empty
if [ -d "$HOME/.config/efm-langserver" ] && [ -z "$(ls -A "$HOME/.config/efm-langserver")" ]; then
    echo "REMOVING empty directory: $HOME/.config/efm-langserver"
    rmdir "$HOME/.config/efm-langserver"
fi

printf "\n"
echo DONE.
