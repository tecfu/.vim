"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neo Bundle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
Plug 'Shougo/vimproc', {
      \ 'do' : 'make'
      \ }


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
    let g:airline_section_c = airline#section#create_left(['%f'])
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


Plug 'Chiel92/vim-autoformat'
let g:formatterpath = ['/usr/local/bin']
"For javascript, install js-beautify externally
"npm install js-beautify -g


Plug 'neoclide/coc.nvim', {'branch': 'release'}
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" In coc-settings.json: "suggest.enablePreselect": false


"Plug 'kien/ctrlp.vim' "unmaintained
"Plug 'ctrlpvim/ctrlp.vim' "maintained Fork


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


"Vim syntax highlighting and indentation for Svelte 3 components
Plug 'evanleck/vim-svelte'


Plug 'FooSoft/vim-argwrap'
nnoremap <leader>w :ArgWrap<CR>


Plug 'fs111/pydoc.vim'


Plug 'godlygeek/csapprox'


Plug 'godlygeek/tabular'
"Cool, but just use native vim selection
":help object-select
"Conflicts with vim-multiple-cursors
"Plug 'gorkunov/smartpairs.vim'
"let g:smartpairs_uber_mode=1


Plug 'gregsexton/gitv'


Plug 'heavenshell/vim-jsdoc'


Plug 'inkarkat/vim-ArgsAndMore'


Plug 'int3/vim-extradite'


Plug 'itchyny/calendar.vim'


if(DetectCommand('python3'))
  Plug 'vim-vdebug/vdebug'

  let g:vdebug_options = {
  \   'port':9000, 
  \   'path_maps': {
  \   },
  \}
endif


Plug 'kshenoy/vim-signature'


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

Plug 'majutsushi/tagbar'
"{{{
nmap t :TagbarToggle<CR>

"Open tagbar automatically if you're opening Vim with a supported file type
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"Open Tagbar only for specific filetypes
"autocmd FileType c,cpp nested :TagbarOpen

"}}}


Plug 'maksimr/vim-jsbeautify'


if(DetectCommand('npm'))
  Plug 'marijnh/tern_for_vim', {
      \ 'do' :  'cd ~/.vim/bundle/tern_for_vim; npm install'}
endif

"Awesome feature if your machine can handle it. My machine can't handle it
"let g:tern_show_argument_hints = 'on_move'
"let g:tern_show_argument_hints=0


"Plug 'MattesGroeger/vim-bookmarks'


Plug 'mattn/emmet-vim'


Plug 'moll/vim-node'


Plug 'mxw/vim-jsx'


Plug 'nathanaelkane/vim-indent-guides'


"Must be manually triggered by M:/ when SearchComplete plugin enabled
Plug 'othree/eregex.vim'
let g:eregex_default_enable = 0
let g:eregex_force_case = 1
let g:eregex_forward_delim = '/'
let g:eregex_backward_delim = '?'


Plug 'pangloss/vim-javascript'
let b:javascript_fold = 1


"Cool plugin, but useless in terminal vim because no alt key
" Plug 'matze/vim-move'


" Recommended: sudo -S apt-get install silversearcher-ag
Plug 'mileszs/ack.vim'
if executable('ag')
 "let g:ackprg = 'ag --vimgrep'
 let g:ackprg = 'ag --nogroup --nocolor --column'
endif


Plug 'mbbill/undotree'
nnoremap <leader>u :UndotreeToggle<cr>


Plug 'mustache/vim-mustache-handlebars'


Plug 'Peeja/vim-cdo'


Plug 'posva/vim-vue'


Plug 'scrooloose/vim-slumlord'


"{{{
Plug 'Shougo/neomru.vim'


Plug 'Shougo/neoyank.vim'


Plug 'Shougo/unite.vim'
"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Shougo/unite.vim Plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable history yank source
let g:unite_source_history_yank_enable = 1

let g:unite_update_time = 1000

" set up mru limit
let g:unite_source_file_mru_limit = 5

" highlight like my vim
let g:unite_cursor_line_highlight = 'CursorLine'

" format mru
let g:unite_source_file_mru_filename_format = ':~:.'
let g:unite_source_file_mru_time_format = ''

" set up  arrow prompt
let g:unite_prompt = '➜ '

" Save session automatically.
let g:unite_source_session_enable_auto_save = 1

" Unite Commands ===============================================================

" No prefix for unite, leader that bish
" nnoremap [unite] <Nop>

" scroll through available files
" nnoremap <silent> <leader>n :Unite buffer file file_mru -auto-preview<CR>
nnoremap <silent> <leader>f :Unite buffer file file_mru<CR>

" key search through available files
nnoremap <silent> <leader>s :<C-u>Unite -no-split file -start-insert<CR>

" ;f Fuzzy Find Everything
" files, Buffers, recursive async file search
" nnoremap <silent> <leader>d :<C-u>Unite -buffer-name=files file_rec/async<CR>

" ;y Yank history
" Shows all your yanks, when you accidentally overwrite
nnoremap <silent> <leader>y :<C-u>Unite -buffer-name=yanks history/yank<CR>

" ;o Quick outline, see an overview of this file
nnoremap <silent> <leader>o :<C-u>Unite -buffer-name=outline -vertical outline<CR>

" ;m MRU All Vim buffers, not file buffer
nnoremap <silent> <leader>m :<C-u>Unite -buffer-name=mru file_mru<CR>

" ;b view open buffers
nnoremap <silent> <leader>b :<C-u>Unite -buffer-name=buffer buffer<CR>

" B
" ;c Quick commands, lists all available vim commands
" nnoremap <silent> <leader>c :<C-u>Unite -buffer-name=commands command<CR>


" Unite motions ================================================================

" Function that only triggers when unite opens
autocmd FileType unite call s:unite_settings()

function! s:unite_settings()
  
  setlocal modifiable

  " Play nice with supertab
  "let b:SuperTabDisabled=1

  " Support autocompletion with tab at cost of actions menu
  "imap <silent><buffer> <tab> <c-x><c-f>
  " iunmap <silent><buffer> <c-n>
  " iunmap <silent><buffer> <c-p>
  "imap <buffer> <S-Tab> <c-p>
  
  " exit with esc
  " nmap <buffer> <ESC> <Plug>(unite_exit)
  " imap <buffer> <ESC> <Plug>(unite_exit)

  " Ctrl jk mappings
  nmap <buffer> <C-j> 5j
  nmap <buffer> <C-k> 5k

  " Enable navigation with shift-j and shift-k in insert mode
  imap <buffer> <S-j>  <Plug>(unite_select_next_line)
  imap <buffer> <S-k>  <Plug>(unite_select_previous_line)
  
  " refresh unite
  nmap <buffer> <C-r> <Plug>(unite_redraw)
  "imap <buffer> <C-r> <Plug>(unite_redraw)

  " split control
  inoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  nnoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  inoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nnoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " => Shougo/unite.vim Plugin Postprocessing
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "{{{
  " Use the fuzzy matcher for everything
  call unite#filters#matcher_default#use(['matcher_fuzzy'])

  " Use the rank sorter for everything
  call unite#filters#sorter_default#use(['sorter_rank'])

  " Set up some custom ignores
  call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
        \ 'ignore_pattern', join([
        \ '\.git/',
        \ 'git5/review/',
        \ 'google/obj/',
        \ 'tmp/',
        \ 'lib/Cake/',
        \ 'node_modules/',
        \ 'vendor/',
        \ 'Vendor/',
        \ 'app_old/',
        \ 'acf-laravel/',
        \ 'plugins/',
        \ 'bower_components/',
        \ '.sass-cache',
        \ 'web/wp',
        \ ], '\|'))
  "}}}


" Unite custom menus ================================================================

  " Fugitive menu in Unite (depends on both Fugitive and Unite.vim) {{{
  endfunction
"}}}

if !has('nvim')
 
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


Plug 'terryma/vim-multiple-cursors'


Plug 'tomtom/tcomment_vim'


"Plug 'tpope/vim-abolish'
"Abolish overwrites :S command in othree/eregex.vim


Plug 'tpope/vim-fugitive'
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


"Fork
"This plugin hijacks the search mappings /,? and thus
"other plugins that augment search won't work right
"i.e. othree/eregex
Plug 'Dewdrops/SearchComplete'
"Plug 'vim-scripts/SearchComplete'


"Fucking cool, but using <leader>y w/ Shougo/Unite instead.
"Seems to conflict with issuing [count] macros
Plug 'tecfu/YankRing.vim'


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

call plug#end()


" Required:
filetype plugin indent on
