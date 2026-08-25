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


