"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load Providers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PYTHON PROVIDERS {{{
if has('macunix')
	" OSX
	let g:python3_host_prog = '/usr/local/bin/python3' " -- Set python 3 provider
	let g:python_host_prog = '/usr/local/bin/python2' " --- Set python 2 provider
elseif has('unix')
		" Ubuntu
	let g:python3_host_prog = '/usr/bin/python3' " -------- Set python 3 provider
	let g:python_host_prog = '/usr/bin/python' " ---------- Set python 2 provider
	"Needed for vim appimage. See https://github.com/vim/vim-appimage/releases
	set pythonthreedll=libpython3.10.so
elseif has('win32') || has('win64')
" Windows
endif
" }}}


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
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-lua',
      \ 'coc-explorer',
      \ 'coc-pyright',
      \ '@hexuhua/coc-copilot',
      \ ]

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

"Remap up/down in popupmenu to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"Remap up/down in coc popup to <C-j>, <C-k>
inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

function! CocPumMultipleTimes(action, count)
    let l:result = ''
    if a:action == 'next'
        let l:cmd = repeat("\<C-r>=coc#pum#_navigate(1,1)\<CR>", a:count)
    elseif a:action == 'prev'
        let l:cmd = repeat("\<C-r>=coc#pum#_navigate(0,0)\<CR>", a:count)
    else
        return ''
    endif
    return l:cmd
endfunction

" <C-s-j/k> supported by gvim
inoremap <expr><C-S-j> coc#pum#visible() ? CocPumMultipleTimes('next', 5) : "\<C-S-j>"
inoremap <expr><C-S-k> coc#pum#visible() ? CocPumMultipleTimes('prev', 5) : "\<C-S-k>"

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
" - AI
" ```
Plug 'github/copilot.vim'


" ```
" - Makes Gvim only colorschems work in term / nc with neovim
" ```
Plug 'godlygeek/csapprox'


" ```
" - POLYFILL: Neovim Healthcheck
" ```
Plug 'rhysd/vim-healthcheck'


" ```
" - THEME
"   See .vimrc for switching logic
" ```
Plug 'tecfu/tokyonight-vim'
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1
set background=dark
set termguicolors
autocmd VimEnter * colorscheme tokyonight
