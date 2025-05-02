Plug 'liuchengxu/vista.vim'

" Executable used when opening vista sidebar without specifying it.
" See all the avaliable executables via `:echo g:vista#executives`.
if g:nvim_config == 'coc'
  let g:vista_default_executive = 'coc'
elseif g:nvim_config == 'cmp'
  let g:vista_default_executive = 'nvim_lsp'
else
  throw "Invalid NVIM_CONFIG value: " . g:nvim_config
endif

nno <silent> <leader>v :<C-u>Vista!!<CR>
