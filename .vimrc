" │      vimrc by Tecfu               │
" ┌───────────────────────────────────┐
" ├───────────────────────────────────┤
" │ http://github.com/tecfu           │
" └───────────────────────────────────┘
" Inspired by https://github.com/lucascaton/vimfiles

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Sections:
"  -> Load Plugins
"  -> Clipboard Settings
"  -> User Interface
"  -> Key Mappings
"  -> Text Folding, Tab, and Indent Related
"  -> Filetype Specific Settings
"  -> Files, Backups, Undo, and Sessions
"  -> Status Line
"  -> Helper Functions
"  -> Readline Config
"  -> Misc
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Set utf8 as standard encoding and en_US as the standard language
" Neovim requires it be done here
set encoding=utf8
set fileencoding=utf8

" For running nvim on git bash in windows
if has('win32') || has('win64')
  " This is a message to confirm the block is running. You can remove it later.
  echom "Configuring shell for Windows..."

  " Locate a real bash.exe to use as &shell (needed by plugins like
  " vim-airline that shell out for git status, etc.) Don't hardcode a
  " single install path -- Git for Windows may be installed per-machine
  " (e.g. "C:/Program Files/Git") or per-user (e.g. under
  " "AppData/Local/Programs/Git"), so derive it from wherever `git` itself
  " resolves on PATH, falling back to common install locations.
  function! s:FindGitBash() abort
    let l:git_path = exepath('git')
    if !empty(l:git_path)
      " git.exe lives at "<GitRoot>/cmd/git.exe" or "<GitRoot>/bin/git.exe"
      let l:git_root = fnamemodify(l:git_path, ':h:h')
      for l:candidate in [l:git_root . '/usr/bin/bash.exe', l:git_root . '/bin/bash.exe']
        if filereadable(l:candidate)
          return l:candidate
        endif
      endfor
    endif

    for l:candidate in [
          \ 'C:/Program Files/Git/usr/bin/bash.exe',
          \ 'C:/Program Files (x86)/Git/usr/bin/bash.exe',
          \ expand('~/AppData/Local/Programs/Git/usr/bin/bash.exe'),
          \ ]
      if filereadable(l:candidate)
        return l:candidate
      endif
    endfor

    return ''
  endfunction

  let s:git_bash = s:FindGitBash()
  if !empty(s:git_bash)
    " 1. Set the shell executable. Use forward slashes.
    let &shell = s:git_bash

    " 2. Set the flag to execute a command string.
    let &shellcmdflag = '-c'

    " 3. CRITICAL: Tell Neovim NOT to add extra quotes around the command.
    " This fixes the ""git ..."" error.
    let &shellxquote = ''
  else
    echom "WARNING: Could not find Git Bash (bash.exe) on this machine. Leaving 'shell' at its default; some plugins (e.g. vim-airline git status) may not work."
  endif
endif

" Check if $NVIM_CONFIG is empty (unset variables often evaluate to empty)
if empty($NVIM_CONFIG)
  " If it is empty, set an internal global Vimscript variable g:nvim_config
  let g:nvim_config = "cmp-builtin"
else
  " Otherwise, set the internal variable to the value of the environment variable
  let g:nvim_config = $NVIM_CONFIG
endif

" Initialize CoC variables (used in echo message even if not in CoC mode)
if empty($COC_PROFILE)
  let g:coc_profile = "default"
else
  let g:coc_profile = $COC_PROFILE
endif

let g:coc_profile_dir = expand('$HOME/.vim/coc-profiles/') . g:coc_profile
let g:coc_config_home = g:coc_profile_dir

function! s:ShowStartupMessage()
  let msg = "NVIM_CONFIG=" . g:nvim_config
  if g:nvim_config == 'coc'
    let msg = msg . " | COC_PROFILE=" . get(g:, 'coc_profile', 'unset') . " | COC_CONFIG_HOME=" . get(g:, 'coc_config_home', 'unset')
  endif
  call s:ScheduleEchoMessage(msg, 500)
endfunction

augroup DelayedEchoMsg
  autocmd!
  autocmd VimEnter * call s:ShowStartupMessage()
augroup END

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if has("nvim")
  source $HOME/.vim/config-nvim.vim
else
  source $HOME/.vim/config-vim.vim
endif

" vim-plug unexpectedly configures indentation. undo this
" https://vi.stackexchange.com/questions/10124/what-is-the-difference-between-filetype-plugin-indent-on-and-filetype-indent
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Clipboard Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" 1. Detect if we are running in WSL
" -------------------------------------------------------------
let s:is_wsl = 0
if has('unix') && filereadable('/proc/version')
    let s:version_lines = readfile('/proc/version')
    if s:version_lines[0] =~? 'microsoft'
        let s:is_wsl = 1
    endif
endif

" 2. Linux Native Configuration (xsel)
" -------------------------------------------------------------
" Fixes truncation/race conditions on Linux (XFCE/Gnome)
" Only runs if NOT in WSL, NOT on Mac, and xsel is present.
if has("unix") && !has("macunix") && !s:is_wsl && executable("xsel")
  let g:clipboard = {
    \   'name': 'xsel_override',
    \   'copy': {
    \      '+': 'xsel --nodetach -i -b',
    \      '*': 'xsel --nodetach -i -p',
    \    },
    \   'paste': {
    \      '+': 'xsel -o -b',
    \      '*': 'xsel -o -p',
    \   },
    \   'cache_enabled': 1,
    \ }
endif

" 3. WSL Configuration (clip.exe)
" -------------------------------------------------------------
" Syncs yank to Windows clipboard
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if s:is_wsl && executable(s:clip)
  augroup WSLYank
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

" 4. Clipboard Mappings
" -------------------------------------------------------------
" Allow pasting from clipboard without autoindenting
" If your ssh session has X11 forwarding enabled, and the remote terminal Vim has +xclipboard support, then you can use the
" "+P keystroke to paste directly from the clipboard into Vim.
nnoremap <leader>p :execute 'set noai' <bar> execute 'normal "+p' <bar> execute 'set ai' <CR>
" Paste from clipboard before cursor
nnoremap <leader>P :execute 'set noai' <bar> execute 'normal "+P' <bar> execute 'set ai' <CR>

" Set the 'P' keybinding to paste from the 0 register. This allows you to repeastedly
" paste the same value instead of subsequent pastes having the previously deleted value
" This prevents replacing the yank register with deleted text in visual mode.
xnoremap <expr> P (v:register ==# '"' ? '"0' : '') . 'P'

" Paste from clipboard in Insert mode
inoremap <C-v> <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>
"}}}


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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"" pum menu mappings
" disabled because of coc / keep for reference
"" Map <S-Tab> and <C-k> to previous entry only if pum menu is visible
"inoremap <expr> <S-Tab> pumvisible() ? "<C-p>" : "<S-Tab>"
"inoremap <expr> <C-k> pumvisible() ? "<C-p>" : "<C-k>"
"
"" Map <Tab> and <C-j> to next entry only if pum menu is visible
"inoremap <expr> <Tab> pumvisible() ? "<C-n>" : "<Tab>"
"inoremap <expr> <C-j> pumvisible() ? "<C-n>" : "<C-j>"
"
"" Map <ESC> to exit pum menu without selecting anything
"inoremap <expr> <ESC> pumvisible() ? "<C-e>" : "<ESC>"
"
"" Map <CR> to select current entry in pum menu
"inoremap <expr> <CR> pumvisible() ? "<C-y>" : "<CR>"

" map leader to spacebar
map <space> <leader>

" Treat long lines as break lines (useful when moving around in them)
nnoremap j gj
nnoremap k gk

" Map ctrl+j, ctrl+k to down/up 10 lines
" Scroll up/down 5 lines at a time shift+j,shift+k
noremap <C-j> 5j
noremap <C-k> 5k
"
" " Scroll ght/left 5 characters
noremap <C-l> 5l
noremap <C-h> 5h

" Remap home and end to "ctrl+;" and ";" in addition to default "1" and "$"
noremap <leader>a ^
noremap <leader>; $

" Remap find char so not lost by easymotion override
noremap <leader>f f
noremap <leader>F F

" Custom function to set the foldlevel of the file to the number entered
function s:SetFoldLevel()
    call inputsave()
    let l:level = input("Enter desired foldlevel: ")
    call inputrestore()
    exe "set foldlevel=" . l:level
    echon "\r\r"
    echon ''
    echo "Set foldlevel to ".l:level
endfunction
nnoremap <leader>fl :call <SID>SetFoldLevel()<CR><ESC>


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
"map <C-t> :tabnew<CR>

" Undo close tab using Shougo/Unite to get MRU file
"function! UndoCloseTab()
"  :tabnew
"  :tabm -1
"  :Unite file_mru
"  exe "normal! 2ggf/gf"
"endfunction
"nmap <C-u> :call UndoCloseTab()<CR><ESC>

" Switch CWD to the directory of the open buffer
" map <leader>cd :cd %:p:h<cr>:pwd<cr>


" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv


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


" Clear highlighting on escape in normal mode
" http://stackoverflow.com/questions/11940801/mapping-esc-in-vimrc-causes-bizzare-arrow-behaviour
nnoremap <esc>^[ <esc>^[
nnoremap <esc> <silent> :noh<return><esc>

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

" insert space in normal mode
" nnoremap <leader>l a<space><esc>

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

" netrw navigation
let g:prev_buf = -1
let g:prev_tab = -1

" Define a function to open netrw in a new tab at the current working directory of the current buffer
function! OpenNetrwInNewTab()
  " Store the current buffer and tab numbers in the global variables
  let g:prev_buf = bufnr('%')
  let g:prev_tab = tabpagenr()
  let l:current_dir = expand('%:p:h')
  tabnew
  execute 'lcd' fnameescape(l:current_dir)
  let g:netrw_browse_split = 0
  Ex
endfunction

" Map <C-t> to call the OpenNetrwInNewTab function
nnoremap <C-t> :call OpenNetrwInNewTab()<CR>

" Exit netrw on <ESC> or q and return to the previous buffer and tab if they exist
augroup NetrwCustom
  autocmd!
  autocmd FileType netrw nnoremap <buffer> <Esc> :call CloseNetrwAndReturn()<CR>
  autocmd FileType netrw nnoremap <buffer> q :call CloseNetrwAndReturn()<CR>
augroup END

" Define a function to close netrw and return to the previous buffer and tab if they exist
function! CloseNetrwAndReturn()
  if g:prev_tab > 0 && g:prev_buf > 0 && bufexists(g:prev_buf)
    execute 'bd'
    execute 'tabnext' g:prev_tab
    execute 'buffer' g:prev_buf
  else
    execute 'bd'
  endif
endfunction
"}}}


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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Filetype Specific Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Alternatively can use ./after/ftplugin/ to add file specific settings
" https://vi.stackexchange.com/questions/3177/use-single-ftplugin-for-more-than-one-filetype
" Easier to apply groupings here

augroup FiletypeSettings
  autocmd!
  " Use setfiletype (not `set filetype=`) so this acts only as a fallback
  " and doesn't refire the FileType event when vim-markdown's ftdetect
  " (which runs earlier, on BufRead/BufNewFile) already set it -- the
  " previous `set filetype=markdown` here fired FileType markdown a second
  " time for every markdown buffer, doubling markdown/html/css/xml syntax
  " sourcing cost on every :e of a .md file (~90ms wasted).
  autocmd BufNewFile,BufReadPost *.md setfiletype markdown
  autocmd BufNewFile,BufRead coc-settings.json,*.jsonc setfiletype jsonc
  autocmd BufNewFile,BufRead *.cjs setfiletype javascript
  autocmd BufEnter *.nvim :setlocal filetype=vim

  " Filetype specific syntax highlighting and indentation
  autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
  autocmd FileType markdown setlocal shiftwidth=2 tabstop=2
  autocmd FileType python,yaml setlocal ts=2 sts=2 sw=2 expandtab

  " Setting foldmethod=marker disables folding
  autocmd Filetype nvim,vim,vimrc,uml
    \ setlocal foldmethod=marker foldmarker=\"{{{,\"}}} foldlevel=1
    \ ts=2 sts=2 sw=2 expandtab

  " Set foldlevel to the deepest level of the file
  " See: https://superuser.com/questions/567352/how-can-i-set-foldlevelstart-in-vim-to-just-fold-nothing-initially-still-allowi
  autocmd Filetype javascript,typescript
    \ let &foldlevel=max(map(range(1, line('$')), 'foldlevel(v:val)'))
augroup END

"======================================================================
" => Better Markdown Folding
"======================================================================
" This autocmd group sets up custom folding for markdown files.
augroup MarkdownFolding
    " Clear any existing autocommands in this group to prevent duplication
    autocmd!
    " When a markdown file is opened, set our custom folding rules.
    autocmd FileType markdown setlocal foldmethod=expr foldexpr=MarkdownLevel() foldlevel=1
    autocmd FileType markdown setlocal spell
augroup END

" The function that determines the fold level of each line in a markdown file.
function! MarkdownLevel()
    " --- CHECK IF INSIDE A FENCED CODE BLOCK ---
    " searchpairpos() is perfect for finding matching fences.
    " 'nbW' means: search backwards ('b'), don't update cursor ('n'), no wrap ('W').
    let start_fence = searchpairpos('^```', '', '^```', 'nbW')

    " If start_fence[0] is not 0, we found an opening fence before the current line.
    if start_fence[0] != 0
        " Now search forward for the closing fence from the line where the block started.
        let end_fence = searchpairpos('^```', '', '^```', 'nW', 'line("'.start_fence[0].'")')
        " If the block is unclosed (end_fence[0] == 0) or we are before the closing fence,
        " then we are inside a code block. Return '=' to keep it at the same fold level.
        if end_fence[0] == 0 || v:lnum < end_fence[0]
            return '='
        endif
    endif

    " --- If not in a code block, check for headers ---
    let line = getline(v:lnum)

    " Match ATX-style headers (e.g., # Header, ## Header).
    let atx_level = len(matchstr(line, '^#\+'))
    " Check that there's a space after the hashes, which is required by spec.
    if atx_level > 0 && atx_level < len(line) && line[atx_level] == ' '
        return '>' . atx_level
    endif

    " Match Setext-style headers by looking at the *next* line.
    if v:lnum < line('$') " Make sure we're not on the last line
        let next_line = getline(v:lnum + 1)
        if line !~ '^\s*$' " Current line must not be blank
            if next_line =~ '^=\+$' " Next line is all '='
                return '>1'
            elseif next_line =~ '^\-+$' " Next line is all '-'
                return '>2'
            endif
        endif
    endif

    " If it's not a header or inside a code block, it's regular content.
    return '='
endfunction


augroup FiletypeSpell
  autocmd!
  autocmd Filetype text
    \ setlocal spell
augroup END

augroup no_filetype
  autocmd!
  autocmd BufEnter * if &filetype ==# '' | setlocal nospell | endif
augroup END
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, Backups, Undo, and Sessions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Automatic <EOL> detection
set fileformats=unix,dos,mac

" Use Vim's persistent undo
" Put plugins and dictionaries in this dir (also on Windows)

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
  let vimDir = has('nvim') ? '$HOME/.config/nvim' : '$HOME/.vim'
  let &runtimepath.=','.vimDir
  let myUndoDir = expand(vimDir . '/undo')
  " Create dirs without spawning a shell (mkdir() is a Vim builtin) and only
  " when missing -- avoids two process spawns on every single startup.
  if !isdirectory(myUndoDir)
    call mkdir(myUndoDir, 'p')
  endif
  let &undodir = myUndoDir
  set undofile
  set undolevels=1000         " How many undos
  set undoreload=10000        " number of lines to save for undo
endif
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Status Line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Always show the status line
set laststatus=2
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
function! ExecuteHighlighted()
    let l:old_reg = @"
    normal! gv"vy
    let l:command = @"
    let l:commands = split(l:command, "\n")
    redraw!
    let l:timestamp = strftime("%Y-%m-%d %H:%M:%S")
    redir => l:output
    echohl Identifier | echom "\nExecuteHighlighted (" . l:timestamp . "):\n" | echohl None
    for cmd in l:commands
        echohl Identifier | echom "> " . cmd | echohl None
        let l:cmd_output = system(cmd)
        " Remove any trailing newlines or unwanted characters
        let l:cmd_output = substitute(l:cmd_output, '\n\+$', '', '')
        echohl Normal | echom l:cmd_output | echohl None
    endfor
    redir END
    silent! echom l:output
    let @" = l:old_reg
endfunction
xnoremap <leader>x :<C-u>call ExecuteHighlighted()<CR>

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

" Stringify JSON
command! -range=% StringifyJSON <line1>,<line2>!jq -r tostring | sed 's/\"/\\"/g' | echo "\"$(cat)\""
vnoremap <silent> <leader>s :!jq -r tostring \| sed 's/"/\\"/g' \| echo "\"$(cat)\""<CR>

function! s:ScheduleEchoMessage(message, delay_ms)
  let l:timer_id = timer_start(a:delay_ms, function('s:EchoMessageCallback', [a:message]))
endfunction

function! s:EchoMessageCallback(message, timer_id)
  echom a:message
endfunction
"}}}


function! s:FormatTable() range
  " ---- collect lines ----
  let l:lines = getline(a:firstline, a:lastline)
  if empty(l:lines) | return | endif

  " ---- parse every row into trimmed cells ----
  " Each line looks like:  [whitespace] | cell | cell | ...
  " We strip ALL leading whitespace before parsing so mixed-indent tables
  " are handled correctly.  Indentation of the output is taken from whichever
  " non-blank line has the least leading whitespace.
  let l:rows    = []   " list-of-lists  (string cells)
  let l:is_sep  = []   " 1 when the row is a separator (---|---) row

  for l:raw in l:lines
    " Strip leading and trailing whitespace from the whole line
    let l:line = substitute(l:raw, '^\s*\|\s*$', '', 'g')

    " Strip the surrounding outer pipes, then split on inner pipes
    let l:inner = substitute(l:line, '^|\(.*\)|$', '\1', '')
    let l:parts = split(l:inner, '|', 1)

    " Trim each cell
    let l:cells = map(copy(l:parts), 'substitute(v:val, "^\\s*\\|\\s*$", "", "g")')

    " A separator row has every non-empty cell matching /^[-: ]+$/
    let l:sep = 1
    for l:c in l:cells
      if l:c !~# '^[-: ]*$'
        let l:sep = 0
        break
      endif
    endfor

    call add(l:rows,   l:cells)
    call add(l:is_sep, l:sep)
  endfor

  " ---- find original indentation (minimum leading whitespace of table lines) ----
  let l:indent = ''
  let l:min_ws = -1
  for l:raw in l:lines
    if l:raw =~# '^\s*|'
      let l:ws = len(matchstr(l:raw, '^\s*'))
      if l:min_ws < 0 || l:ws < l:min_ws
        let l:min_ws = l:ws
        let l:indent = matchstr(l:raw, '^\s*')
      endif
    endif
  endfor

  " ---- determine column count ----
  let l:ncols = 0
  for l:row in l:rows
    if len(l:row) > l:ncols | let l:ncols = len(l:row) | endif
  endfor

  " ---- compute per-column max widths (from data rows only) ----
  let l:widths = repeat([0], l:ncols)
  for l:ri in range(len(l:rows))
    if l:is_sep[l:ri] | continue | endif   " skip separator rows
    let l:row = l:rows[l:ri]
    for l:i in range(len(l:row))
      let l:w = strdisplaywidth(l:row[l:i])
      if l:w > l:widths[l:i] | let l:widths[l:i] = l:w | endif
    endfor
  endfor

  " Separator cells need at least 3 dashes
  for l:i in range(l:ncols)
    if l:widths[l:i] < 3 | let l:widths[l:i] = 3 | endif
  endfor

  " ---- re-render ----
  let l:new_lines = []
  for l:ri in range(len(l:rows))
    let l:row   = l:rows[l:ri]
    let l:parts = []
    for l:i in range(l:ncols)
      let l:cell = get(l:row, l:i, '')
      let l:w    = l:widths[l:i]
      if l:is_sep[l:ri]
        let l:cell = repeat('-', l:w)
      else
        let l:pad  = l:w - strdisplaywidth(l:cell)
        if l:pad < 0 | let l:pad = 0 | endif
        let l:cell = l:cell . repeat(' ', l:pad)
      endif
      call add(l:parts, ' ' . l:cell . ' ')
    endfor
    call add(l:new_lines, l:indent . '|' . join(l:parts, '|') . '|')
  endfor

  call setline(a:firstline, l:new_lines)
endfunction

command! -range=% FormatTable <line1>,<line2>call s:FormatTable()

" <leader>tf: auto-detect the table block around the cursor and format it
function! TableFormat()
  let l:start = line('.')
  let l:end   = line('.')
  while l:start > 1 && getline(l:start - 1) =~# '^\s*|'
    let l:start -= 1
  endwhile
  while l:end < line('$') && getline(l:end + 1) =~# '^\s*|'
    let l:end += 1
  endwhile
  execute l:start . ',' . l:end . 'call s:FormatTable()'
  echo 'Table formatted (' . (l:end - l:start + 1) . ' rows)'
endfunction
nnoremap <leader>tf :call TableFormat()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Readline Config (When vim is launched from shell vi mode)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If Vim is launched from shell vi mode (`V`), switch to shell's PWD
" Automatically change the working directory for temporary files from git, etc.
augroup SetWorkingDirectoryForShell
  autocmd!
  " Use BufEnter with specific file patterns for a reliable trigger.
  autocmd BufEnter COMMIT_EDITMSG,MERGE_MSG,TAG_EDITMSG,*.tmp,*/tmp/*
        " Use a safe execution method to handle paths with spaces.
        \ if $PWD != ''
        \ | silent! execute 'lcd' fnameescape($PWD)
        \ | endif
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Remove the Windows ^M - when the encodings gets messed up noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
" Never run in vi-compatible mode
set nocompatible

" Enable tab autocomplete of commands in command mode"
set wildmode=longest,list,full

" Set incremental search
" Makes search act like search in modern browsers
" This way you can :/findsomething to see all current matches
" and then :%s//replace will use the last command (:/findsomething)
" http://stackoverflow.com/questions/1276403/simple-vim-commands-you-wish-youd-known-earlier?page=1&tab=votes#tab-top
set incsearch

" Tell vim to split # between filename and anchor name, thus gF on filename will also hop to anchors in files
set isfname-=#

" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

set showcmd


" Tell Vim to look for a tags file in the directory of the current file as well as in the working directory, and up, and up, and…
" alt-j
set tags=./tags,tags;/

"}}}
