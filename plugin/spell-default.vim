" Unset filetype buffers: no spell
augroup no_filetype
  autocmd!
  autocmd BufEnter * if &filetype ==# '' | setlocal nospell | endif
augroup END
