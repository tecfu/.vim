"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => User Interface / UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Set vim to true color
" You might have to force true color when using regular vim inside tmux as the
" colorscheme can appear to be grayscale with "termguicolors" option enabled.
if (has("unix") && !has("macunix"))
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
""}}}

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0

" set guifont=monospace\ 11
" See plugins.vim for color scheme selection

" Set color column
set colorcolumn=80
" Guard against re-enabling syntax when it's already on (e.g. via
" $VIMRUNTIME/defaults.vim, sourced earlier). Calling `:syntax on` a second
" time triggers `:highlight clear`, which makes Vim re-source the active
" colorscheme file (colors/tokyonight.vim) a second time on every startup.
if !exists('g:syntax_on')
  syntax on
endif

" Set relative line numbers except in insert mode
" set relativenumber
" autocmd InsertEnter * :set norelativenumber
" autocmd InsertLeave * :set relativenumber

" Text highlight of words that match that under the cursor
" http://stackoverflow.com/questions/1551231/highlight-variable-under-cursor-in-vim-like-in-netbeans
" :autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" Disable wildmenu to prevent conflicts with coc, nvim-cmp 
" set wildmenu

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
set visualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
"set foldcolumn=1

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
augroup RestoreCursorPosition
  autocmd!
  autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
augroup END

" Save buffer list. Slows vim dramatically when in big project.
" Disabled.
" set viminfo^=%

" New splits to appear to the right and to the bottom of the current
set splitbelow
set splitright

" Vertically center buffer when entering insert mode
augroup CenterOnInsert
  autocmd!
  autocmd InsertEnter * norm zz
augroup END

"}}}


