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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugins-vim')

  " - common plugins"
  source ${HOME}/.vim/config-common.vim

  " - Coc.nvim"
  source $HOME/.vim/viml/coc-nvim.vim

  " - AI
  Plug 'github/copilot.vim'


  " - Makes Gvim only colorschems work in term / nc with neovim
  Plug 'godlygeek/csapprox'


  " - POLYFILL: Neovim Healthcheck
  Plug 'rhysd/vim-healthcheck'


  " - THEME
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

  Plug 'tecfu/tokyonight-vim'
  "let g:tokyonight_style = 'night'
  let g:tokyonight_enable_italic = 1
  set termguicolors

  " Define a function to set the colorscheme and background color
  function! SetColorscheme()
    highlight Normal guibg=#222436 ctermbg=235
    highlight EndOfBuffer guibg=#222436 ctermbg=235
  endfunction

  " Use an autocmd to call the function on VimEnter with ++once to ensure it runs only once
  autocmd VimEnter * ++once call SetColorscheme()


call plug#end()

colorscheme tokyonight
