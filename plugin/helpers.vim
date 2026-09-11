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
function! s:StringifyJSON() range abort
  " Native JSON support avoids the POSIX pipeline when Windows uses cmd.exe.
  let l:input = join(getline(a:firstline, a:lastline), "\n")
  let l:value = json_decode(l:input)
  " Keep numeric tokens intact: Vim's numeric conversions can lose precision.
  let l:text = type(l:value) == v:t_string ? l:value : l:input
  call setline(a:firstline, json_encode(l:text))
  if a:lastline > a:firstline
    call deletebufline(bufnr(), a:firstline + 1, a:lastline)
  endif
endfunction
command! -range=% StringifyJSON <line1>,<line2>call s:StringifyJSON()
vnoremap <silent> <leader>s :StringifyJSON<CR>

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
