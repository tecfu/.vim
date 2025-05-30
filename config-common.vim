"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HELPER FN: CHECK SYSTEM DEPENDENCY
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"function! DetectCommand(name, ...)
"  " see: https://vi.stackexchange.com/a/2437/5223
"  let warn = a:0 >= 1 ? a:1 : 1
"  if(system('command -v '.a:name) != '')
"    return 1
"  else
"    if(warn && $WARN_MISSING_PLUGINS)
"      echom 'Plugin dependency not found: '.a:name
"    endif
"    return 0
"  endif
"endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => CUSTOM HELPER LIBRARIES
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  source $HOME/.vim/viml/library-tab-completion.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HELPER FN: DETECT PLUGIN
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
function! DetectPlugin(name)
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
    return 1
  else
    echoerr 'Plugin '.a:name.' not detected'
    return 0
  endif
endfunction
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => COMMON PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Plug 'airblade/vim-gitgutter'
if has('nvim')
  let g:gitgutter_sign_removed_first_line = "^_"
  let g:gitgutter_highlight_lines = 1
endif
"let g:gitgutter_highlight_linenrs = 1


Plug 'ap/vim-css-color'


Plug 'bling/vim-airline'
"{{{
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
"}}}


Plug 'bronson/vim-visual-star-search'


"```
"- Automatically puts bullet points in markdown
"```
Plug 'bullets-vim/bullets.vim'


"```
"- Use `:rename[!] {newname}`to rename a buffer within Vim and on the disk
"```
Plug 'danro/rename.vim'


Plug 'dhruvasagar/vim-table-mode'
function! s:isAtStartOfLine(mapping)
 let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'


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


" ```
" - FORMATTING: Wrap parameter arguments
" ```
Plug 'FooSoft/vim-argwrap'
nnoremap <leader>w :ArgWrap<CR>


" ```
" - THEME
"   See .vimrc for switching logic
" ```
Plug 'goatslacker/mango.vim'


" ```
" - FORMATTING: Create a table
" ```
Plug 'godlygeek/tabular'
"{{{
function s:VIMRC_CustomTabular() range
    call inputsave()
    let l:char = input("Enter desired character to align by:")
    call inputrestore()
    exe ":Tabularize /" . l:char
    echon "\r\r"
    echon ''
    echo "Tabularized by: ".l:char
endfunction
nnoremap <leader>tz :call <SID>VIMRC_CustomTabular()<CR><ESC>
vnoremap <leader>tz :call <SID>VIMRC_CustomTabular()<CR><ESC>
"}}}


"Conflicts with vim-multiple-cursors
"Plug 'gorkunov/smartpairs.vim'
"let g:smartpairs_uber_mode=1


" ```
" - Markdown Previewer (vim || nvim)
" ```
" @todo - this is not working on Mac nivm brew install
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
" set to 1, nvim will open the preview window after entering the Markdown buffer
" default: 0
let g:mkdp_auto_start = 0
" use a custom port to start server or empty for random
let g:mkdp_port = '20000'
" use custom IP to open preview page.
" Useful when you work in remote Vim and preview on local browser.
" For more details see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = ''


" ```
" - UTILITY COMMAND: Argdo / Windo /
" ```
Plug 'inkarkat/vim-ArgsAndMore'


" ```
" - WIDGET: Calendar
" ```
Plug 'itchyny/calendar.vim'


" ```
" - THEME
"   This is run when we are on an Apple device
"   See .vimrc for switching logic
" ```
Plug 'joshdick/onedark.vim'


" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'

" Use tabular.vim instead, its does the same with less complexity
"Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
"xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
"nmap ga <Plug>(EasyAlign)


Plug 'jupyter-vim/jupyter-vim'


" Plug 'kien/ctrlp.vim'


"```
"- Displays marks in the gutter
"```
Plug 'kshenoy/vim-signature'


" ```
" - CTAGS
" ```
" Think these are redundant with lsp go to definition
"sudo apt install universal-ctags
"Plug 'ludovicchabant/vim-gutentags'
"set statusline+=%{gutentags#statusline()}

"```
"- Colorizes pairs of opening/closing parens, braces, etc
"```
Plug 'luochen1990/rainbow'
"{{{
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
"}}}


" doesn't play nice with permissions restricted users
" probably not needed with lsp
"Plug 'preservim/tagbar'
"{{{
""nmap <leader>tt :TagbarToggle<CR>

"Open tagbar automatically if you're opening Vim with a supported file type
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"Open Tagbar only for specific filetypes
"autocmd FileType c,cpp nested :TagbarOpen
"}}}


" - Folds markdown correctly when codeblocks are used
" - Maps `ge` to follow anchors in markdown
Plug 'preservim/vim-markdown'
"{{{
" Displays nice headings in markdown
let g:vim_markdown_folding_style_pythonic = 1
" does a simple search of the anchor text with `silent! execute '/'.l:anchor `
" not needed given `set isfname-=#`, which will tell vim to split # between filename and anchor name
" let g:vim_markdown_follow_anchor = 1
" let g:vim_markdown_edit_url_in = 'tab'
"}}}


" ```
" - DEBUGGER
" ```
" We use this instead of nvim-dap because it supports easy setup of 
" vscode-jd-debug, which is required for typescript
" Plug 'puremourning/vimspector'
" let g:vimspector_enable_mappings = 'HUMAN'
" let g:vimspector_install_gadgets = ['vscode-js-debug', 'debugger-for-chrome', 'vscode-firefox-debug', 'debugpy', 'delve']
" nmap <leader>db <Plug>VimspectorBreakpoints
" " autocmd VimEnter * VimspectorUpdate
" " Resume / Pause (Control+\)
" nmap <C-\> :call vimspector#Continue()<CR>
" " Step Over (Control+')
" nmap <C-'> :call vimspector#StepOver()<CR>
" " Step Into (Control+;)
" nmap <C-;> :call vimspector#StepInto()<CR>
" " Step Out (Control+Shift+;)
" nmap <C-S-;> :call vimspector#StepOut()<CR>
" " Toggle Breakpoint (Control+Shift+Leader)
" nmap <leader>bp :call vimspector#ToggleBreakpoint()<CR>


"Plug 'MattesGroeger/vim-bookmarks'


Plug 'mechatroner/rainbow_csv'
let g:rbql_meta_language='Javascript'


Plug 'moll/vim-node'


Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_start_level = 2


"Must be manually triggered by M:/ when SearchComplete plugin enabled
Plug 'othree/eregex.vim'
"{{{
let g:eregex_default_enable = 0
let g:eregex_force_case = 1
let g:eregex_forward_delim = '/'
let g:eregex_backward_delim = '?'
"}}}


" ```
" - TEXT SEARCH
" ```
" Recommended: sudo -S apt-get install silversearcher-ag
Plug 'mileszs/ack.vim'
if executable('ag')
 "let g:ackprg = 'ag --vimgrep'
 let g:ackprg = 'ag --nogroup --nocolor --column'
endif


" ```
" - UNDO
" ```
Plug 'mbbill/undotree'
nnoremap <leader>u :UndotreeToggle<cr>


"Vim 8 adds almost identical native :cdo and :ldo commands, with additional functionality.
"https://vimhelp.org/version8.txt.html#new-items-8
" Plug 'Peeja/vim-cdo'


" ```
" - GIT: Show branch convergence/divergence,
"   depends on fugitive
"   depends on vim > 9.1
"   disabled due to dependencies
"
" ```
" Plug 'rbong/vim-flog'


" ```
" - WIDGET: Open Vim from Browser
" ```
" Grouped together as vim-hug-neovim-rpc and nvim-yarp are deps of vim-ghost
"Plug 'roxma/vim-hug-neovim-rpc'
"Plug 'SpaceVim/nvim-yarp'
"Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}
""{{{
"function! s:SetupGhostBuffer()
"    if match(expand("%:a"), '\v/ghost-(github|bitbucket|gitlab)\.com-')
"        set ft=markdown
"    endif
"endfunction
"
"" Automatically open vim
"" let g:ghost_darwin_app = 'vim'
"augroup vim-ghost
"    au!
"    au User vim-ghost#connected call s:SetupGhostBuffer()
"augroup END
"}}}


Plug 'scrooloose/vim-slumlord'
" Use a split window to view output
" let g:slumlord_separate_win=1


" interferes with remapping default register for `p` in visual mode
" Plug 'sickill/vim-pasta'


" YankRing interferes with remapping default register for `p` in visual mode
Plug 'tecfu/YankRing.vim'


" ```
" - GIT: Switch branches quickly (fugitive plugin) run :Merginal
" ```
Plug 'tecfu/vim-merginal'
autocmd FileType merginal nnoremap <buffer> <Enter> :MerginalCheckout<CR>
nnoremap <leader>b :Merginal<CR>


" Move highlighted text
Plug 'tecfu/vim-move'
let g:move_key_modifier_visualmode = 'S'


"<c-p>,<c-n> here cause conflict with yank plugins (YankRing)
"Plug 'terryma/vim-multiple-cursors'


"Plug 'tpope/vim-abolish'
"Abolish overwrites :S command in othree/eregex.vim


Plug 'tpope/vim-commentary'


Plug 'tpope/vim-fugitive'
"{{{
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

" Alias Gcheckout to Gread
command! Gcheckout Gread
"}}}


Plug 'tpope/vim-rhubarb'


Plug 'tpope/vim-obsession'


Plug 'tpope/vim-surround'


Plug 'tpope/vim-unimpaired'


" Doesn't work in Vim8
" Plug 'valloric/MatchTagAlways'
" let g:mta_filetypes = {
"     \ 'html' : 1,
"     \ 'jinja' : 1,
"     \ 'xhtml' : 1,
"     \ 'xml' : 1,
"     \ 'vue' : 1
"     \}
" nnoremap <leader>t :MtaJumpToOtherTag<cr>
" highlight MatchTag ctermfg=black ctermbg=lightgreen

source $HOME/.vim/viml/vista.vim
