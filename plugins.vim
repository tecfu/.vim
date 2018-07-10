
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neo Bundle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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


Plug 'blindFS/vim-taskwarrior'

"set code folding for plugin
au Filetype taskreport 
  \ setlocal foldmethod=marker |
  \ setlocal foldlevel=0 |
  \ setlocal foldlevelstart=0


"unmap <S-j>, <S-k> in plugin so can map it to tabprev,tabnext

"Found three different techniques to do this, since
"autocmd FileType taskreport unmap K
"won't work because keys are mapped later.
"
" 1 - Comment out keymapping directly in plugin 
" :verbose map K
" 
" 2 - Create||edit .vim/after/ftplugin/filetype.vim
" unmap k
"
" 3 - Make async call via a job (as below)
function! TWUnmap(a,b)
  unmap <buffer><silent> J
  unmap <buffer><silent> K
endfunction

function! TWUnmapChooser()
  if has("nvim")
    call jobstart(['bash','-c','echo "-"; exit;'],{'on_stdout':'TWUnmap'})
  else
    call job_start(['bash','-c','echo "-"; exit;'],{'out_cb':'TWUnmap'})
  endif
endfunction

augroup TaskwarriorMapping
  autocmd!
  autocmd FileType taskreport :call TWUnmapChooser() 
augroup END


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


"Plug 'kien/ctrlp.vim' "unmaintained
"Plug 'ctrlpvim/ctrlp.vim' "maintained Fork


Plug 'danro/rename.vim'


Plug 'dhruvasagar/vim-table-mode'


"If tab completion runs slow, check that you don't have too many
"open buffers
Plug 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "<c-n>"


"Run commands such as go run for the current file with <leader>r or go build and go test for the current package with <leader>b and <leader>t respectively. Display beautifully annotated source code to see which functions are covered with <leader>c. 
Plug 'fatih/vim-go'
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)


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


"Plug 'hhvm/vim-hack'


Plug 'int3/vim-extradite'


Plug 'itchyny/calendar.vim'


Plug 'vim-vdebug/vdebug'

let g:vdebug_options = {
\   'port':9000, 
\   'path_maps': {
\   },
\}


Plug 'kshenoy/vim-signature'


Plug 'Lokaltog/vim-easymotion'
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


Plug 'majutsushi/tagbar'
"{{{
nmap t :TagbarToggle<CR>

"Open tagbar automatically if you're opening Vim with a supported file type
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"Open Tagbar only for specific filetypes
"autocmd FileType c,cpp nested :TagbarOpen

"}}}


Plug 'maksimr/vim-jsbeautify'


Plug 'marijnh/tern_for_vim', {
    \ 'do' :  'cd ~/.vim/bundle/tern_for_vim; npm install'}

"Awesome feature if your machine can handle it.
let g:tern_show_argument_hints = 'on_move'
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


Plug 'm2mdas/phpcomplete-extended'
"{{{
let g:phpcomplete_index_composer_command = "composer"
"}}}


"Cool plugin, but useless in terminal vim because no alt key
" Plug 'matze/vim-move'


" Recommended: sudo -S apt-get install silversearcher-ag
Plug 'mileszs/ack.vim'
if executable('ag')
 "let g:ackprg = 'ag --vimgrep'
 let g:ackprg = 'ag --nogroup --nocolor --column'
endif


Plug 'mbbill/undotree'
nnoremap <leader>t :UndotreeToggle<cr>


Plug 'mustache/vim-mustache-handlebars'


Plug 'OrangeT/vim-csharp'


Plug 'Peeja/vim-cdo'


Plug 'posva/vim-vue'


Plug 'scrooloose/vim-slumlord'


function! SyntasticPostInstall(info)
  "install jshint
  "!npm install jshint -g

  "check jshint is installed
  if(system('command -v jshint') == '')
    "remove plugin
    !rm -rf ~/dotfiles/.vim/bundle/syntastic
    throw 'Warning: jshint not installed. Plugin removed.'
  else
    echom 'jshint found'
  endif

  echom 'End postinstall'
endfunction

Plug 'scrooloose/syntastic', {
    \ 'do' :  function('SyntasticPostInstall')}

"{{{


function! OnLoadSyntastic()
  
  if DetectPlugin('syntastic')
    
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:syntastic_reuse_loc_lists = 1

    " javascript  
    "  let g:syntastic_javascript_checkers = ['eslint']
    let g:syntastic_javascript_checkers = ['jshint']
    
  " java
    "let g:syntastic_java_checker = 'javac'
    
  " manage custom filetypes
    augroup filetype
      autocmd! BufRead,BufNewFile  *.gradle  set filetype=gradle
      au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
    augroup END

    let g:syntastic_filetype_map = { "gradle": "java" }

    set sessionoptions-=blank

    " Set location list height to n lines
    let g:syntastic_loc_list_height=5

  endif
endfunction

"Wait until VimEnter to see if plugin loaded
autocmd VimEnter * call OnLoadSyntastic()

"}}}


"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Shougo/neocomplete Plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use deoplete with nvim
if has("nvim")
  Plug 'Shougo/deoplete.nvim'
  let g:deoplete#enable_at_startup = 1
" Use neomplete with vim
else
  Plug 'Shougo/neocomplete'

  "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
  " Disable AutoComplPop.
  let g:acp_enableAtStartup = 0
  " Use neocomplete.
  let g:neocomplete#enable_at_startup = 1
  " Use smartcase.
  let g:neocomplete#enable_smart_case = 1
  " Set minimum syntax keyword length.
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
  \ 'default' : '',
  \ 'vimshell' : $HOME.'/.vimshell_hist',
  \ 'scheme' : $HOME.'/.gosh_completions'
  \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  "inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction

  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()
  
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
  " autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  " autocmd FileType javascript setlocal omnifunc=tern#Complete

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.javascript = '[^. \t]\.\w*'
  "}}}

  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif
  let g:neocomplete#force_omni_input_patterns.go = '[^.[:digit:] *\t]\.'

endif

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
  imap <silent><buffer> <Tab>   <Plug>SuperTabForward
  imap <silent><buffer> <S-Tab>  <Plug>SuperTabBackward
  nnoremap <silent><buffer> <S-Tab> <Plug>SuperTabBackward
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
  let g:unite_source_menu_menus = {}
  let g:unite_source_menu_menus.git = {}
  let g:unite_source_menu_menus.git.description = 'git (Fugitive)'
  let g:unite_source_menu_menus.git.command_candidates = [
      \['▷ git status       (Fugitive)',
          \'Gstatus'],
      \['▷ git diff         (Fugitive)',
          \'Gdiff'],
      \['▷ git commit       (Fugitive)',
          \'Gcommit'],
      \['▷ git log          (Fugitive)',
          \'exe "silent Glog | Unite quickfix"'],
      \['▷ git blame        (Fugitive)',
          \'Gblame'],
      \['▷ git stage        (Fugitive)',
          \'Gwrite'],
      \['▷ git checkout     (Fugitive)',
          \'Gread'],
      \['▷ git rm           (Fugitive)',
          \'Gremove'],
      \['▷ git mv           (Fugitive)',
          \'exe "Gmove " input("destino: ")'],
      \['▷ git push         (Fugitive, output buffer)',
          \'Git! push'],
      \['▷ git pull         (Fugitive, output buffer)',
          \'Git! pull'],
      \['▷ git prompt       (Fugitive, output buffer)',
          \'exe "Git! " input("comando git: ")'],
      \['▷ git cd           (Fugitive)',
          \'Gcd'],
      \]
"" }}}
"
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


Plug 'shawncplus/phpcomplete.vim'


Plug 'sickill/vim-pasta'


Plug 'sidorares/node-vim-debugger', {
      \ 'do' : 'npm i vimdebug -g'
      \ }

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
  execute 'Gdiff ' . a:hash
  "echom a:hash
endfunction
command! -nargs=1 GdiffPrev call DiffPrev(<f-args>)

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


"Fork
"This plugin hijacks the search mappings /,? and thus
"other plugins that augment search won't work right
"i.e. othree/eregex
Plug 'Dewdrops/SearchComplete'
"Plug 'vim-scripts/SearchComplete'


"Fucking cool, but using <leader>y w/ Shougo/Unite instead.
"Seems to conflict with issuing [count] macros
Plug 'tecfu/YankRing.vim'


" Ale replaces syntastic because it lints continuously, i.e. on wordchange <KINDA ANNOYING, SLOW AS SHIT ON BIG PROJECTS>
"Plug 'w0rp/ale', {
"    \ 'do' :  'npm install jshint -g'}
"
""let g:ale_linters = {
""\ 'javascript': ['jshint'],
""\}
"" Show warnings/errors in status line
"let g:airline#extensions#ale#enabled = 1
"let g:ale_sign_column_always = 1
"let g:ale_open_list = 1


call plug#end()

" Required:
filetype plugin indent on
