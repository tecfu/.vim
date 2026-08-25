"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text Folding, Tab, and Indent Related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Linebreak on 500 characters
set lbr
set tw=500

" Indentation tweaks:
set autoindent "Auto indent
"set si "Smart indent
set wrap "Wrap lines

" Global code fold settings. Overridden by filetype in ./after/ftplugin/
set foldmethod=indent
set foldlevel=2

" Show invisibles by default
set list

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" Replace tab character with empty spaces
" if this is broken, make sure there is no .editorconfig file inherited
set expandtab

" Enable filetype plugins
" This may override the tabstop, softtabstop, shiftwidth
"filetype plugin on
"filetype indent on

" Make "tab" insert indents instead of tabs at the beginning of a line
set smarttab

" Prefer spaces to tabs and set size to 2
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Global Code Folding Default
setlocal foldmethod=indent
setlocal foldlevel=2

" Map <C-d> to duplicate tab
nnoremap <C-d> :tab split<CR>
"}}}


