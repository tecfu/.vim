Plug 'liuchengxu/vista.vim'

" Executable used when opening vista sidebar without specifying it.
" See all the avaliable executables via `:echo g:vista#executives`.
if $NVIM_CONFIG == 'coc'
  let g:vista_default_executive = 'coc'
elseif $NVIM_CONFIG == 'cmp'
  let g:vista_default_executive = 'nvim_lsp'
else
  throw "Invalid NVIM_CONFIG value: " . $NVIM_CONFIG
endif

nno <silent> <leader>v :<C-u>Vista!!<CR>
