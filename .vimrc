" ┌───────────────────────────────────┐
" │      vimrc by Tecfu               │
" ├───────────────────────────────────┤
" │ http://github.com/tecfu           │
" └───────────────────────────────────┘
" Inspired by https://github.com/lucascaton/vimfiles

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Sections:
"    -> Load Plugins
"    -> General
"    -> VIM user interface
"    -> Printer setup
"    -> Colors and Fonts
"    -> Files, backups, and sessions
"    -> Text, tab and indent related
"    -> Visual mode related
"    -> Moving around, tabs and buffers
"    -> Status line
"    -> Key mappings
"    -> vimgrep searching and cope displaying
"    -> Misc
"    -> Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load Plugins 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set utf8 as standard encoding and en_US as the standard language
" Neovim requires it be done here
set encoding=utf8
set fileencoding=utf8

"Python fix for neovim
if has("nvim")
  "set shell=/bin/bash
  if !has('python') && !has('python3')
    echoe "ERROR! Manually install python support with:\n"
          \"pip2 install neovim\n" 
          \"pip3 install neovim"
  endif

  let g:python_host_prog = '/usr/bin/python'
endif


if filereadable($HOME."/.vim/plugins.vim")
  source ${HOME}/.vim/plugins.vim
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neovim Specific
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Fixes unsupported prompt character
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{

" Never run in vi-compatible mode
set nocompatible

" Enable tab autocomplete of commands in command mode"
set wildmode=list:longest

" Set incremental search
" Makes search act like search in modern browsers
" This way you can :/findsomething to see all current matches
" and then :%s//replace will use the last command (:/findsomething)
" http://stackoverflow.com/questions/1276403/simple-vim-commands-you-wish-youd-known-earlier?page=1&tab=votes#tab-top
set incsearch

" Sets how many lines of history VIM has to remember
set history=700

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" map leader to spacebar
"nnoremap <Space> <nop>
"let mapleader = " "
"let g:mapleader = " "
map <space> <leader>
imap <space><space> <C-O><leader>
set showcmd


" http://stackoverflow.com/questions/6778961/alt-key-shortcuts-not-working-on-gnome-terminal-with-vim/10216459#10216459
" Useless, because setting the alt-somekey will always work like esc-sokekey
 " while c <= 'z'
 "   let c='a'
 "   exec "set <A-".c.">=\e".c
 "   exec "imap \e".c." <A-".c.">"
 "   let c = nr2char(1+char2nr(c))
 " endw


" Tell Vim to look for a tags file in the directory of the current file as well as in the working directory, and up, and up, and…
" alt-j
set tags=./tags,tags;/

" Set shell instances to use globstar
set shell=/bin/bash\ -O\ globstar

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Set color column 
set colorcolumn=80

" Set relative line numbers except in insert mode
set relativenumber
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber

" Text highlight of words that match that under the cursor
" http://stackoverflow.com/questions/1551231/highlight-variable-under-cursor-in-vim-like-in-netbeans
" :autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\')) 

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,.build.*,.so,*.a
if has("win16") || has("win32")
    set wildignore+=*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.hg\*,.svn\*
endif

"Show line numbers
set number

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Search for visually selected text by pressing // in visual mode
vnoremap // y/<C-R>"<CR>

" Search within range in visual mode
" http://vim.wikia.com/wiki/Search_only_over_a_visual_range
function! RangeSearch(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'.(line("'<")-1).'l'.
          \ '\%<'.(line("'>")+1).'l'
  else
    let g:srchstr = ''
  endif
endfunction
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>

" Ignore case when searching
set ignorecase

" See :help 'smartcase'
" Assumes lowercase searches insensitive,
" Uppercase searches sensitive
" Will also make substitutions insensitive, so
" set the I flag on a substitution to force the pattern to be case-sensitive. Like :%s/lowercasesearch/replaceString/gI
set smartcase

" Highlight search results
set hlsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Highlight matching parentheses when cursor is over one
" Don't use showmatch, use DoMatchParen / NoMatchParen
"set showmatch

" Change color of opposing highlighted cursor to avoid confusion
hi MatchParen ctermbg=red guibg=lightblue

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1

" Code folding
set foldmethod=indent
set foldlevel=2

" Filetype specific folding
au Filetype vim,vimrc,md 
  \ setlocal foldmethod=marker |
  \ setlocal foldlevel=0 |
  \ setlocal foldlevelstart=0

"au Filetype js,ts
"  \ setlocal foldmethod=syntax

au Filetype php
  \ setlocal foldmethod=syntax |
  \ setlocal foldlevel=0 |
  \ setlocal foldlevelstart=0


au Filetype uml
  \ setlocal foldmethod=marker |
  \ setlocal foldlevel=0 |
  \ setlocal foldlevelstart=0

" Use Vim's persistent undo
" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undo')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
    set undolevels=1000         " How many undos
    set undoreload=10000        " number of lines to save for undo
endif

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Printer setup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set pdev=HP_LASERJET_4000
set popt=paper:letter,header:0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Clear highlighting on escape in normal mode
" http://stackoverflow.com/questions/11940801/mapping-esc-in-vimrc-causes-bizzare-arrow-behaviour
nnoremap <esc>^[ <esc>^[
nnoremap <esc> <silent> :noh<return><esc>

" ctrl-q to force quit
noremap <C-Q> :qa!<CR>
vnoremap <C-Q> <C-C>:qa!<CR>
inoremap <C-Q> <C-O>:qa!<CR>

" Use CTRL-S for saving
" Must add the following to ~/.bashrc for this to work
" alias vim="stty stop '' -ixoff ; vim"
function! CustomSave()
  "Save the buffer
  "execute 'w!'
  :w!
endfunction
  
"noremap <C-S> :w!<CR>
noremap <C-S> :call CustomSave()<CR>
vnoremap <C-S> <C-C>:call CustomSave()<CR><ESC>
inoremap <C-S> <C-O>:call CustomSave()<CR><ESC>

" Map delete to black hole register
"nnoremap d "_d
"vnoremap d "_d

" Split lines leader+k [This frees up <S-k> for tabnext
noremap <leader>k i<CR><ESC>k

" Join lines on leader+j [This frees up <S-j> for tabprev
noremap <leader>j <S-j>

" Paste after cursor, next line down
"nmap p :pu<CR>

"insert a new-line after the current line by pressing Enter (Shift-Enter for inserting a line before the current line)
"nmap <S-Enter> O<Esc>
"nmap <CR> o<Esc>

" Map shift+tab to inverse tab
" for normal mode
nmap <S-Tab> <<
" for insert mode
"imap <S-Tab> <Esc><<i

" Delete trailing white space on save, useful for Python and CoffeeScript
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()

" Delete all buffers except those open in windows / tabs
" http://stackoverflow.com/questions/1534835/how-do-i-close-all-buffers-that-arent-shown-in-a-window-in-vim/7321131#7321131
function! DeleteInactiveBufs()
    "From tabpagebuflist() help, get a list of all buffers in all tabs
    let tablist = []
    for i in range(tabpagenr('$'))
        call extend(tablist, tabpagebuflist(i + 1))
    endfor

    "Below originally inspired by Hara Krishna Dara and Keith Roberts
    "http://tech.groups.yahoo.com/group/vim/message/56425
    let nWipeouts = 0
    for i in range(1, bufnr('$'))
        if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
        "bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
            silent exec 'bwipeout' i
            let nWipeouts = nWipeouts + 1
        endif
    endfor
    echomsg nWipeouts . ' buffer(s) wiped out'
endfunction
command! DeleteInactiveBuffers :call DeleteInactiveBufs()

" map escape key for nvim terminal
if has("nvim")
  tnoremap <Esc> <C-\><C-n>
endif
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups, undo, and sessions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Automatic <EOL> detection
set fileformats=unix,dos,mac

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Show invisibles by default
set list

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" Replace tab character with empty spaces
set expandtab
" Use tabs, not spaces
" set noexpandtab

" Make "tab" insert indents instead of tabs at the beginning of a line
set smarttab

" Prefer spaces to tabs and set size to 2
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Syntax of these languages is fussy over tabs Vs spaces
autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Linebreak on 500 characters
set lbr
set tw=500

" Indentation tweaks:
set ai "Auto indent
"set si "Smart indent
set wrap "Wrap lines

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Select all
function! SelectAll()
  :mark l  
  ":exe 'normal ggVG'
  :%
endfunction
nnoremap <C-a> :call SelectAll()<CR>

" Allow pasting from clipboard without autoindenting
" If your ssh session has X11 forwarding enabled, and the remote terminal Vim has +xclipboard support, then you can use the "+P keystroke to paste directly from the clipboard into Vim.
  nnoremap <leader>p :execute 'set noai' <bar> execute 'normal "+p' <bar> execute 'set ai' <CR>
  "Paste from clipboard before cursor
  nnoremap <leader>P :execute 'set noai' <bar> execute 'normal "+P' <bar> execute 'set ai' <CR>

inoremap <C-v> <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>
inoremap <leader>p <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>

" Paste a space in normal mode
" nnoremap <leader>l a<space><esc> 
nnoremap <leader>l $a<space><esc> 

"}}} 

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
  
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{

" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
"5 left
cnoremap <C-S-h> <C-f>5h<C-c>
"5 right
cnoremap <C-S-l> <C-f>5l<C-c>

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Map ctrl+j, ctrl+k to down/up 10 lines
" Scroll up/down 10 lines at a time shift+j,shift+k
noremap <C-j> 10j
noremap <C-k> 10k
" 
" " Scroll ght/left 10 characters
noremap <C-l> 10l 
noremap <C-h> 10h  

" Remap home and end to "ctrl+;" and ";" in addition to default "1" and "$" 
noremap <leader>a ^
noremap <leader>; $

"noremap <C-a> ^
"<C-;> does not map
"nmap <C-e> $ 

" Disable highlight when <leader><cr> is pressed
" map <silent> <leader><cr> :noh<cr>

" Navigation shortcuts for location window
" map <leader>q :lopen <CR>
"  map q :lclose <CR>
map <expr> <C-Down> (empty(getloclist(0))  ? "" : ":lnext")."<CR>"
map <expr> <C-Up> (empty(getloclist(0))  ? "" : ":lp")."<CR>"

" Navigation shortcuts for quickfix window
map <expr> <A-Down> (empty(getqflist())  ? "" : ":cnext")."<CR>"
map <expr> <A-Up> (empty(getqflist())  ? "" : ":cprevious")."<CR>"

" Move between buffers with keycodes that match vimperator
" shift+h => back, shift+l => forward
" noremap <S-h> :bp<CR>
" noremap <S-l> :bn<CR>

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
"Overwrites jump to prev tag
"See: http://vim.wikia.com/wiki/Alternative_tab_navigation
map <S-w> :tabclose<CR>
"Overwrites man for word under cursor
map <S-k> :tabnext<CR>
"Overwrites join lines
map <S-j> :tabprev<CR>
"Because C-t is tag navigation
map <C-t> :tabnew<CR>

" Undo close tab using Shougo/Unite to get MRU file
"function! UndoCloseTab()
"  :tabnew  
"  :tabm -1  
"  :Unite file_mru
"  exe "normal! 2ggf/gf"
"endfunction
"nmap <C-u> :call UndoCloseTab()<CR><ESC>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif

" Save buffer list. Slows vim dramatically when in big project. 
" Disabled.
" set viminfo^=%

" New splits to appear to the right and to the bottom of the current
set splitbelow
set splitright
"}}}


""""""""""""""""""""""""""""""
" => Color Scheme
""""""""""""""""""""""""""""""
"{{{

" One color scheme for all!
  set t_Co=256
  colorscheme mango
  "colorscheme solarized
  "let g:solarized_termcolors=256
  set guifont=monospace\ 11 
  set background=dark
  syntax on
"}}}


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" {{{
" Always show the status line
set laststatus=2
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Remove the Windows ^M - when the encodings gets messed up noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("Ack \"" . l:pattern . "\" " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction
"}}}
