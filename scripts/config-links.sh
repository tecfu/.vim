#!/bin/bash
# Shared by INSTALL.sh and UNINSTALL.sh; sourcing this file has no side effects.
config_paths() {
  CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
  if [ "$WINDOWS" = 1 ] && command -v cygpath >/dev/null 2>&1; then
    CONFIG_HOME="$(cygpath -u "$CONFIG_HOME")"
  fi
  NVIM_CONFIG_DIR="$CONFIG_HOME/nvim"
  if [ "$WINDOWS" = 1 ] && [ -z "${XDG_CONFIG_HOME:-}" ]; then
    NVIM_CONFIG_DIR="${LOCALAPPDATA:-$HOME/AppData/Local}/nvim"
    if command -v cygpath >/dev/null 2>&1; then
      NVIM_CONFIG_DIR="$(cygpath -u "$NVIM_CONFIG_DIR")"
    fi
  fi
  EFM_CONFIG="$CONFIG_HOME/efm-langserver"
}

latest_config_backup() {
  local target="$1" backup latest="" suffix highest=0
  if [ -e "$target.saved" ] || [ -L "$target.saved" ]; then
    latest="$target.saved"
  fi
  for backup in "$target.saved."[0-9]*; do
    [ -e "$backup" ] || [ -L "$backup" ] || continue
    suffix="${backup#"$target.saved."}"
    if [[ "$suffix" =~ ^[1-9][0-9]*$ ]] && [ "$suffix" -gt "$highest" ]; then
      highest="$suffix"
      latest="$backup"
    fi
  done
  printf '%s' "$latest"
}

link_config() {
  local source="$1" target="$2" backup latest index=0
  if [ -L "$target" ] && [ "$(readlink -- "$target")" = "$source" ]; then
    echo "ALREADY SYMLINKED: $target -> $source"
    return 0
  fi
  if [ ! -L "$target" ] && [ "$source" -ef "$target" ]; then
    echo "ALREADY IN PLACE: $target"
    return 0
  fi
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    echo "WARNING: Existing unmanaged directory left untouched: $target"
    return 1
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup="$target.saved"
    latest="$(latest_config_backup "$target")"
    if [ -n "$latest" ]; then
      if [ "$latest" != "$backup" ]; then
        index="${latest#"$target.saved."}"
      fi
      backup="$target.saved.$((index + 1))"
    fi
    echo "BACKING UP: $target -> $backup"
    mv -n -- "$target" "$backup" || return 1
    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "WARNING: Could not safely back up $target; left untouched."
      return 1
    fi
  fi
  echo "SYMLINKING: $target -> $source"
  if ! ln -s -- "$source" "$target"; then
    echo "WARNING: Failed to link $target."
    return 1
  fi
  if [ ! -L "$target" ]; then
    echo "WARNING: $target is a plain copy, not a symlink; rerun INSTALL.sh after repo changes."
    echo "         On Windows, enable Developer Mode or run as Administrator for real symlinks."
  fi
}

unlink_config() {
  local source="$1" target="$2" backup
  if [ ! -L "$target" ] || [ "$(readlink -- "$target")" != "$source" ]; then
    echo "SKIPPING: $target is not a symlink managed by this script."
    return 0
  fi
  backup="$(latest_config_backup "$target")"
  echo "REMOVING SYMLINK: $target"
  rm -- "$target" || return 1
  if [ -n "$backup" ]; then
    echo "RESTORING BACKUP: $backup -> $target"
    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "WARNING: Cannot restore $backup: $target now exists."
      return 1
    fi
    mv -n -- "$backup" "$target" || return 1
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      echo "WARNING: Could not safely restore $backup; backup left untouched."
      return 1
    fi
  fi
}
