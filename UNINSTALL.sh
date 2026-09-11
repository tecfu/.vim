#!/bin/bash
# Remove only matching managed links; leave copies and unmanaged paths alone.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
WINDOWS=0
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; esac
. "$DIR/scripts/config-links.sh"
config_paths

STATUS=0
unlink_config "$DIR/.vimrc" "$HOME/.vimrc" || STATUS=1
unlink_config "$DIR/init.vim" "$NVIM_CONFIG_DIR/init.vim" || STATUS=1
unlink_config "$DIR/coc-settings.json" "$NVIM_CONFIG_DIR/coc-settings.json" || STATUS=1
unlink_config "$DIR/efm-langserver-config.yaml" "$EFM_CONFIG/config.yaml" || STATUS=1
unlink_config "$DIR/efm-langserver-linter-wrapper.sh" "$EFM_CONFIG/efm-langserver-linter-wrapper.sh" || STATUS=1
# Remove the repo link last: DIR may itself have been reached through ~/.vim.
unlink_config "$DIR" "$HOME/.vim" || STATUS=1
exit "$STATUS"
