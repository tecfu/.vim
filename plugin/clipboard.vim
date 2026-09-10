"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Clipboard Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" 1. Detect if we are running in WSL
" -------------------------------------------------------------
let s:is_wsl = 0
if has('unix') && filereadable('/proc/version')
    let s:version_lines = readfile('/proc/version')
    if s:version_lines[0] =~? 'microsoft'
        let s:is_wsl = 1
    endif
endif

" 2. Linux Native Configuration (xsel)
" -------------------------------------------------------------
" Fixes truncation/race conditions on Linux (XFCE/Gnome)
" Only runs if NOT in WSL, NOT on Mac, and xsel is present.
if has("unix") && !has("macunix") && !s:is_wsl && executable("xsel")
  let g:clipboard = {
    \   'name': 'xsel_override',
    \   'copy': {
    \      '+': 'xsel --nodetach -i -b',
    \      '*': 'xsel --nodetach -i -p',
    \    },
    \   'paste': {
    \      '+': 'xsel -o -b',
    \      '*': 'xsel -o -p',
    \   },
    \   'cache_enabled': 1,
    \ }
endif

" 3. WSL Configuration (clip.exe)
" -------------------------------------------------------------
" Syncs yank to Windows clipboard
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if s:is_wsl && executable(s:clip)
  augroup WSLYank
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

" 3b. OSC 52 Fallback (headless servers over SSH)
" -------------------------------------------------------------
" If no real clipboard tool was found above (xsel/WSL/etc.), emit the OSC 52
" escape sequence so yanks land on the LOCAL machine's clipboard through the
" SSH stream. Requires nvim >= 0.10 and a local terminal that supports
" OSC 52 (kitty, alacritty, wezterm, foot, Windows Terminal, tmux with
" `set -s set-clipboard on`). VTE terminals (gnome-/xfce4-terminal) ignore it.
if has('nvim-0.10') && !exists('g:clipboard')
  lua << EOF
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
  }
EOF
endif

" 4. Clipboard Mappings
" -------------------------------------------------------------
" Allow pasting from clipboard without autoindenting
" If your ssh session has X11 forwarding enabled, and the remote terminal Vim has +xclipboard support, then you can use the
" "+P keystroke to paste directly from the clipboard into Vim.
nnoremap <leader>p :execute 'set noai' <bar> execute 'normal "+p' <bar> execute 'set ai' <CR>
" Paste from clipboard before cursor
nnoremap <leader>P :execute 'set noai' <bar> execute 'normal "+P' <bar> execute 'set ai' <CR>

" Set the 'P' keybinding to paste from the 0 register. This allows you to repeastedly
" paste the same value instead of subsequent pastes having the previously deleted value
" This prevents replacing the yank register with deleted text in visual mode.
xnoremap <expr> P (v:register ==# '"' ? '"0' : '') . 'P'

" Paste from clipboard in Insert mode
inoremap <C-v> <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>
"}}}


