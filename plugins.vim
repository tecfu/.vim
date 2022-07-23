function! DetectCommand(name, ...)
  " see: https://vi.stackexchange.com/a/2437/5223
  let warn = a:0 >= 1 ? a:1 : 1
  if(system('command -v '.a:name) != '')
    return 1
  else
    if(warn && $WARN_MISSING_PLUGINS)
      echom 'Plugin dependency not found: '.a:name
    endif
    return 0
  endif
endfunction

"requires grep
function! DetectPlugin(name)
  "
  "check if plugin found in scriptnames
  redir @z 
  silent scriptnames
  redir END 

  let l:scriptnameFound = system('echo '.shellescape(@z)
        \.' | grep -ci "'.a:name.'"')
  
  let l:helpFound = 0
  try
    "we don't care about output here, only whether error is thrown
    silent execute "h ".a:name." | q"
    let l:helpFound = 1
  catch
    let l:helpFound = 0
  endtry

  if (l:scriptnameFound || l:helpFound)
    echom 'Plugin '.a:name.' detected'
    return 1
  else
    echoerr 'Plugin '.a:name.' not detected'
    return 0
  endif
  
endfunction

" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/bundle')


" Custom Plugins Start Here

" UML syntax highlighting for scrooloose/vim-slumlord
Plug 'aklt/plantuml-syntax'
" Use a split window to view output
" let g:slumlord_separate_win=1


Plug 'airblade/vim-gitgutter'
if has('nvim')
  let g:gitgutter_sign_removed_first_line = "^_"
endif


Plug 'altercation/vim-colors-solarized'


Plug 'bling/vim-airline'
" {{{
"let g:airline_theme='colors/mango.vim'
let g:airline_powerline_fonts=1

"airline themed tabs
"let g:airline#extensions#tabline#enabled = 1

function! OnLoadAirline(...)
  if DetectPlugin('airline')

    let g:airline_section_a = airline#section#create(['mode'])
    let g:airline_section_b = airline#section#create_left(['branch'])
    let g:airline_section_c = airline#section#create_left(['%F'])
    let g:airline_section_y = airline#section#create([])

    if !exists('g:airline_symbols')
      let g:airline_symbols = {}
    endif

    " unicode symbols
    let g:airline_left_sep = '»'
    let g:airline_right_sep = '«'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.whitespace = 'Ξ'

    " airline symbols
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''

  endif
endfunction

autocmd VimEnter * call OnLoadAirline()

" }}}


Plug 'brookhong/DBGPavim'


Plug 'bronson/vim-visual-star-search'


"Plug 'Chiel92/vim-autoformat'
"let g:formatterpath = ['/usr/local/bin']
"For javascript, install js-beautify externally
"npm install js-beautify -g

" coc.nvim is used for file formatting
" can be configurated to auto format on save in coc-settings.json
" Use "coc.preferences.formatOnType": true to enable format on type feature.
" https://vi.stackexchange.com/a/31087/5223
" https://github.com/neoclide/coc-prettier

" Not a fan of the gray gutter (SignColumn) that comes with the theme
highlight SignColumn guibg=black ctermbg=black

" Not a fan of pink background in popup menu
highlight Pmenu ctermbg=DarkGreen guibg=DarkGreen
" hi CocErrorSign ctermfg=white guifg=white
"hi CocErrorFloat ctermfg=white guifg=white
hi CocErrorFloat ctermfg=white guifg=white
hi CocInfoSign ctermfg=black guifg=black
hi CocFloating ctermfg=black guifg=black
hi CocFloating ctermbg=DarkRed guibg=DarkRed
hi CocHintFloat ctermfg=white guifg=white

"hi CocFloating ctermbg=DarkYellow guibg=DarkYellow
"hi QuickFixLine ctermbg=DarkRed guibg=DarkRed
" hi QuickFixLine ctermbg=yellow guibg=yellow
"hi QuickFixLine ctermfg=white guifg=white


Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
  \ 'coc-eslint',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-pairs',
  \ 'coc-prettier',
  \ 'coc-snippets', 
  \ 'coc-tabnine',
  \ 'coc-tsserver',
  \ 'https://github.com/andys8/vscode-jest-snippets'
  \ ]

" Eslint run autofixes hotkey
noremap <Space>l :CocCommand eslint.executeAutofix<CR><ESC>


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
"" run cmd on range of entire file
""nmap <S-f>  <Plug>(coc-format)%

"Coc Popup Completion settings
"Use <tab> for trigger completion and navigate to the next complete item
 inoremap <silent><expr> <Tab>
   \ pumvisible() ? "\<C-n>" :
   \ coc#expandableOrJumpable() ?
   \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
   \ <SID>check_back_space() ? "\<Tab>" :
   \ coc#refresh()
 
 inoremap <silent><expr> <S-Tab>
   \ pumvisible() ? "\<C-p>" :
   \ coc#expandableOrJumpable() ?
   \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-pre',''])\<CR>" :
   \ <SID>check_back_space() ? "\<Tab>" :
   \ coc#refresh()
 
 function! s:check_back_space() abort
   let col = col('.') - 1
   return !col || getline('.')[col - 1]  =~# '\s'
 endfunction

"Select the first completion item and confirm the completion when no item has been selected:
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Remap up/down in popup to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"


Plug 'chr4/nginx.vim'


Plug 'craigemery/vim-autotag'
let g:autotagStartMethod='fork'


"```
"- Use `:rename[!] {newname}`to rename a buffer within Vim and on the disk
"```
Plug 'danro/rename.vim'


"Cool, but conflicts with tabular
"Plug 'dhruvasagar/vim-table-mode'


Plug 'easymotion/vim-easymotion'
"{{{
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Bi-directional find motion
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap f <Plug>(easymotion-s)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
"nmap f <Plug>(easymotion-s2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
"}}}


Plug 'FooSoft/vim-argwrap'
nnoremap <leader>w :ArgWrap<CR>


"Doesn't support custom keymaps, interferes with <S-k>
"Plug 'fs111/pydoc.vim'


Plug 'godlygeek/csapprox'


Plug 'godlygeek/tabular'
nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>


"Conflicts with vim-multiple-cursors
"Plug 'gorkunov/smartpairs.vim'
"let g:smartpairs_uber_mode=1


" Syntax highlighting for Terraform
Plug 'hashivim/vim-terraform'


Plug 'heavenshell/vim-jsdoc'


Plug 'idanarye/vim-merginal'
autocmd FileType merginal nnoremap <buffer> <Enter> :MerginalCheckout<CR>
nnoremap <leader>b :Merginal<CR>


Plug 'inkarkat/vim-ArgsAndMore'


Plug 'itchyny/calendar.vim'


Plug 'jupyter-vim/jupyter-vim'


"```
"- Displays marks in the gutter
"```
Plug 'kshenoy/vim-signature'


" ```
" - Typescript highlighting
" ```
Plug 'leafgarland/typescript-vim'
let g:typescript_compiler_binary = 'tsc'
let g:typescript_compiler_options = ''
autocmd FileType typescript :set makeprg=tsc


Plug 'luochen1990/rainbow'

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
    \ 'separately': {
    \    'mustache': {
    \      'parentheses': ['start=/{{/ end=/}}/','start=/{{{/ end=/}}}/','start=/{{\(\^\|!\|#\).\{-}}}/ end=/{{\/.\{-}}}/ fold','start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \     },
    \    'vue': {
    \      'parentheses': ['start=/{/ end=/}/ fold contains=@javaScript containedin=@javaScript', 'start=/(/ end=/)/ fold contains=@javaScript containedin=@javaScript', 'start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
        \}
      \}
    \}


" doesn't play nice with permissions restricted users
Plug 'preservim/tagbar'
"{{{
nmap <leader>tt :TagbarToggle<CR>

"Open tagbar automatically if you're opening Vim with a supported file type
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"Open Tagbar only for specific filetypes
"autocmd FileType c,cpp nested :TagbarOpen
"}}}


" - Folds markdown correctly when codeblocks are used
" - Maps `ge` to follow anchors in markdown
Plug 'preservim/vim-markdown'
" Displays nice headings in markdown
let g:vim_markdown_folding_style_pythonic = 1
" does a simple search of the anchor text with `silent! execute '/'.l:anchor `
" not needed given `set isfname-=#`, which will tell vim to split # between filename and anchor name
" let g:vim_markdown_follow_anchor = 1
" let g:vim_markdown_edit_url_in = 'tab'


Plug 'maksimr/vim-jsbeautify'


"Plug 'MattesGroeger/vim-bookmarks'


Plug 'mattn/emmet-vim'


" Move highlighted text
Plug 'tecfu/vim-move'
let g:move_key_modifier_visualmode = 'S'


Plug 'mechatroner/rainbow_csv'
let g:rbql_meta_language='Javascript'


Plug 'moll/vim-node'


Plug 'mxw/vim-jsx'


Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_start_level = 2


"Must be manually triggered by M:/ when SearchComplete plugin enabled
Plug 'othree/eregex.vim'
let g:eregex_default_enable = 0
let g:eregex_force_case = 1
let g:eregex_forward_delim = '/'
let g:eregex_backward_delim = '?'


Plug 'pangloss/vim-javascript'
let b:javascript_fold = 1


"Plug 'preservim/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
"Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
"" Plug 'ryanoasis/vim-devicons'
"" Start NERDTree, highlight file in buffer, and put the cursor back in the other window.
"autocmd VimEnter * NERDTreeFind % | wincmd p


Plug 'puremourning/vimspector'
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = ['vscode-node-debug2', 'debugger-for-chrome', 'vscode-firefox-debug', 'debugpy', 'delve']
nmap <Leader>db <Plug>VimspectorBreakpoints


" Recommended: sudo -S apt-get install silversearcher-ag
Plug 'mileszs/ack.vim'
if executable('ag')
 "let g:ackprg = 'ag --vimgrep'
 let g:ackprg = 'ag --nogroup --nocolor --column'
endif


Plug 'mbbill/undotree'
nnoremap <leader>u :UndotreeToggle<cr>


Plug 'Peeja/vim-cdo'


Plug 'posva/vim-vue'


" Git viewer
Plug 'rbong/vim-flog'


Plug 'scrooloose/vim-slumlord'


if !has('nvim')
  Plug 'Shougo/vimproc', {
      \ 'do' : 'make'
      \ }


  Plug 'Shougo/vimshell'
  " {{{
  let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
  let g:vimshell_prompt =  '$ '
  " open new splits actually in new tab
  let g:vimshell_split_command = "tabnew"

  if has("gui_running")
    let g:vimshell_editor_command = "gvim"
  endif

  " Use same keybindings to go forward and back in prompt as in vim bash
  "inoremap <buffer> <S-k>  <Plug>(vimshell_previous_prompt)
  "inoremap <buffer> <S-j>  <Plug>(vimshell_next_prompt)

  " Unmap C-j, C-k in normal mode to use default navigation
  function! VSmap(a,b)
    nmap <buffer><silent> <C-J> 10j
    nmap <buffer><silent> <C-K> 10k
  endfunction

  function! VSmapChooser()
    if has("nvim")
      call jobstart(['bash','-c','echo "-"; exit;'],{'on_stdout':'VSmap'})
    else
      call job_start(['bash','-c','echo "-"; exit;'],{'out_cb':'VSmap'})
    endif
  endfunction

  "Group name can be arbitrary so long as doesn't conflict with another
  augroup VimshellMapping
    autocmd!
    "Get filetype with :echom &filetype when in buffer
    autocmd FileType vimshell :call VSmapChooser() 
  augroup END
"}}}
endif


Plug 'sickill/vim-pasta'


"only run if npm is installed
if(DetectCommand('npm'))
  Plug 'sidorares/node-vim-debugger', {
      \ 'do' : 'npm i vimdebug -g'
      \ }
endif


Plug 'StanAngeloff/php.vim'


Plug 'stephpy/vim-yaml'


"Plug 'supermomonga/vimshell-inline-history.vim', { 'depends' : [ 'Shougo/vimshell.vim' ] }
Plug 'tecfu/vimshell-inline-history.vim', { 'depends' : [ 'Shougo/vimshell.vim' ] }

function! VSHistmapCB(a,b)
  let g:vimshell_inline_history#default_mappings = 0
  imap <buffer> <C-j>  <Plug>(vimshell_inline_history#next)
  imap <buffer> <C-k>  <Plug>(vimshell_inline_history#prev)
endfunction

function! VSHistmap()
  call job_start(['bash','-c','echo "-"; exit;'],{'out_cb':'VSHistmapCB'})
endfunction

  "Group name can be arbitrary so long as doesn't conflict with another
augroup VSHistMapping
  autocmd!
  "Get filetype with :echom &filetype when in buffer
  autocmd FileType vimshell :call VSHistmap()
augroup END


"Allows you to cycle through yank history
"Conflicts with multiple-cursors start command <C-n>
"To view yank history list, see <leader>y w/ Shougo/Unite
"To cycle yanks with this, use <c-p>, <c-n> after p
Plug 'tecfu/YankRing.vim'


"<c-p>,<c-n> here cause conflict with svermeulen/vim-yoink
"Plug 'terryma/vim-multiple-cursors'


Plug 'tomtom/tcomment_vim'


"Plug 'tpope/vim-abolish'
"Abolish overwrites :S command in othree/eregex.vim


Plug 'tpope/vim-commentary'


Plug 'tpope/vim-fugitive'

"Enable legacy commands (Gpush, Gcommit)
let g:fugitive_legacy_commands=1

"Open split windows vertically
set diffopt+=vertical

"Delete all Git conflict markers
function! RemoveConflictMarkers() range
  execute a:firstline.','.a:lastline . ' g/^<\{7}\|^|\{7}\|^=\{7}\|^>\{7}/d'
endfunction
"-range=% default is whole file
command! -range=% GremoveConflictMarkers <line1>,<line2>call RemoveConflictMarkers()

"Diff the current file against n revision (instead of n commit)
function! DiffPrev(...)
  
  let a:target = @%
 
  "check argument count
  if a:0 == 0
    "no revision number specified
    let a:revnum=0
  else
    "revision number specified
    let a:revnum=a:1
  endif

  let a:hash = system('git log -1 --skip='.a:revnum.' --pretty=format:"%h" ' . a:target)
  execute 'Gdiffsplit ' . a:hash
  "echom a:hash
endfunction
command! -nargs=1 Gdiffprev call DiffPrev(<f-args>)
" You will probably not realize that Gdiff is actually equal to Gdiffsplit
" and therefore be confused when Vim spits `ambiguous user defined command`
" So we're going to make Gdiff explicitly equal to Gdiffsplit
command! Gdiff Gdiffsplit!


Plug 'tpope/vim-obsession'
"{{{

" Sessions
" Using Tim Pope's Obsession Plugin
" automatically restore when session found.
function! RestoreSess()
  if filereadable(".vim/session.vim")
    source .vim/session.vim
  else
    exec 'echo "Warning: No vim session available to restore"'
  endif
endfunction

" autocmd VimEnter * call RestoreSess()
"}}}


Plug 'tpope/vim-surround'


Plug 'tpope/vim-unimpaired'


Plug 'valloric/MatchTagAlways'
let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'jinja' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'vue' : 1
    \}
nnoremap <leader>t :MtaJumpToOtherTag<cr>
highlight MatchTag ctermfg=black ctermbg=lightgreen


if(DetectCommand('python3'))
  Plug 'vim-vdebug/vdebug'

  let g:vdebug_options = {
  \   'port':9000, 
  \   'path_maps': {
  \   },
  \}
endif


call plug#end()

