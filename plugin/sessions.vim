"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, Backups, Undo, and Sessions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Automatic <EOL> detection
set fileformats=unix,dos,mac

" Use Vim's persistent undo
" Put plugins and dictionaries in this dir (also on Windows)

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
  let vimDir = has('nvim') ? stdpath('config') : expand('$HOME/.vim')
  let &runtimepath .= ',' . escape(vimDir, ',')
  let myUndoDir = vimDir . '/undo'
  " Keep existing history when switching to native Windows/XDG config paths.
  if has('nvim') && isdirectory(expand('$HOME/.config/nvim/undo'))
    let myUndoDir = expand('$HOME/.config/nvim/undo')
  endif
  " Create dirs without spawning a shell (mkdir() is a Vim builtin) and only
  " when missing -- avoids two process spawns on every single startup.
  if !isdirectory(myUndoDir)
    call mkdir(myUndoDir, 'p')
  endif
  let &undodir = myUndoDir
  set undofile
  set undolevels=1000         " How many undos
  set undoreload=10000        " number of lines to save for undo
endif
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Status Line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Always show the status line
set laststatus=2
"}}}
