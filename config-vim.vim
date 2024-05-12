"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => APPIMAGE CONFIG
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" See https://github.com/vim/vim-appimage/releases
set pythonthreedll=libpython3.10.so

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LANGUAGE SERVER
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ## vim-lsp ecosystem
"
"{{{
"Plug 'prabirshrestha/vim-lsp'
"Plug 'mattn/vim-lsp-settings'
"Plug 'prabirshrestha/asyncomplete.vim'
"Plug 'prabirshrestha/asyncomplete-lsp.vim'
"
"" ## config
"filetype plugin on
"
"function! s:on_lsp_buffer_enabled() abort
"    setlocal omnifunc=lsp#complete
"    setlocal signcolumn=yes
"    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
"
"    let g:lsp_format_sync_timeout = 1000
"    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
"
"endfunction
"
"augroup lsp_install
"    au!
"    " call s:on_lsp_buffer_enabled (set the lsp shortcuts) when an lsp server
"    " is registered for a buffer.
"    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
"augroup END
"}}}


" ## coc-vim ecosystem

"{{{
" Use "coc.preferences.formatOnType": true to enable format on type feature.
" https://vi.stackexchange.com/a/31087/5223
" https://github.com/neoclide/coc-prettier

" coc ui styling
" Not a fan of the gray gutter (SignColumn) that comes with the theme
highlight SignColumn guibg=black ctermbg=black

" Not a fan of pink background in popup menu
highlight Pmenu ctermbg=DarkGreen guibg=DarkGreen
" hi CocErrorSign ctermfg=white guifg=white
"hi CocErrorFloat ctermfg=white guifg=white
hi CocInfoSign ctermfg=black guifg=black
hi CocFloating ctermfg=black guifg=black
hi CocFloating ctermbg=DarkRed guibg=DarkRed
hi CocHintFloat ctermfg=white guifg=white
hi CocWarningFloat ctermfg=white guifg=white
hi CocErrorFloat ctermfg=white guifg=white
"hi CocFloating ctermbg=DarkYellow guibg=DarkYellow
"hi QuickFixLine ctermbg=DarkRed guibg=DarkRed
"hi QuickFixLine ctermbg=yellow guibg=yellow
"hi QuickFixLine ctermfg=white guifg=white

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" coc extensions
let g:coc_global_extensions = [
      \ 'coc-eslint',
      \ 'coc-json',
      \ 'coc-html',
      \ 'coc-markdownlint',
      \ 'coc-marketplace',
      \ 'coc-pairs',
      \ 'coc-prettier',
      \ 'coc-rome',
      \ 'coc-snippets',
      \ 'coc-tabnine',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'jest-snippets',
      \ 'coc-lua',
      \ 'coc-explorer',
      \ 'coc-copilot',
      \ 'coc-pyright',
      \ '@hexuhua/coc-copilot',
      \ ]

  "\ 'coc-tabnine',
augroup CustomCocMappings
  autocmd!
  autocmd FileType * nmap <silent> <leader>l :call CocAction('format')<CR>
augroup end

" Fix diagnostics popup background color
function! CheckLocationListOpen()
  if get(getloclist(0, {'winid':0}), 'winid', 0)
      " the location window is closed
      return 0
  else
      " the location window is open
      return 1
  endif
endfunction

" Shortcut to diagnostics display in location list
nnoremap <expr> <space>i
  \ (CheckLocationListOpen() ? ":CocDiagnostics" : ":lclose")."<CR>"

"vmap <S-f>  <Plug>(coc-format-selected)
"run cmd on range of entire file
"nmap <S-f>  <Plug>(coc-format)%

"Coc Popup Completion settings
"Use <tab> for trigger completion and navigate to the next complete item
"Modified from docs due to error: https://github.com/neoclide/coc.nvim/issues/3167
inoremap <silent><expr> <Tab>
 \ pumvisible() ? "\<C-n>" :
 \ coc#expandableOrJumpable() ?
 \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<Tab>"

inoremap <silent><expr> <S-Tab>
 \ pumvisible() ? "\<C-p>" :
 \ coc#expandableOrJumpable() ?
 \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-pre',''])\<CR>" : "\<Tab>"

"Select the first completion item and confirm the completion when no item has been selected:
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

"Remap up/down in popup to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"Scroll info popup
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GENERAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ```
" - CTAGS
" ```
Plug 'craigemery/vim-autotag'
let g:autotagStartMethod='fork'


" ```
" - AI
" ```
Plug 'github/copilot.vim'


" ```
" - Makes Gvim only colorschems work in term / nc with neovim
" ```
Plug 'godlygeek/csapprox'


Plug 'joshdick/onedark.vim'

" ```
" - SYNTAX: Typescript
" ```
Plug 'leafgarland/typescript-vim'
let g:typescript_compiler_binary = 'tsc'
let g:typescript_compiler_options = ''
autocmd FileType typescript :set makeprg=tsc


" ```
" - SYNTAX: Javascript
" ```
Plug 'pangloss/vim-javascript'
let b:javascript_fold = 1


" ```
" - SYNTAX: VueJS
" ```
Plug 'posva/vim-vue'


" ```
" - DEBUGGER
" ```
Plug 'puremourning/vimspector'
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = ['vscode-node-debug2', 'debugger-for-chrome', 'vscode-firefox-debug', 'debugpy', 'delve']
nmap <leader>db <Plug>VimspectorBreakpoints


" ```
" - POLYFILL: Neovim Healthcheck
" ```
Plug 'rhysd/vim-healthcheck'


" ```
" - SYNTAX: Various
" ```
Plug 'sheerun/vim-polyglot'


" ```
" - SYNTAX: PHP
" ```
Plug 'StanAngeloff/php.vim'


" ```
" - SYNTAX: YAML
" ```
Plug 'stephpy/vim-yaml'


" ```
" - THEME
"   See .vimrc for switching logic
" ```
Plug 'tecfu/tokyonight-vim'
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1
