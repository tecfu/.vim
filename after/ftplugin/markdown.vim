" Markdown: indentation, spell, fence-aware folding
setlocal shiftwidth=2 tabstop=2
setlocal spell
setlocal foldmethod=expr
setlocal foldexpr=markdownfold#Level(v:lnum)
setlocal foldlevel=1

" gd/gD follow the markdown link under the cursor, like a definition jump.
" Note: vim-markdown's <Plug>Markdown_OpenUrlUnderCursor is unusable on nvim 0.12+:
" it matches on legacy mkd* syntax regions, which treesitter highlighting replaced.
" ponytail: inline [text](target) links only; reference-style links and #anchors fall
" through to the "not on a link" message — extend here if they turn up in real docs.
" Definition guard (same pattern vim-markdown uses for its s:EditUrlUnderCursor):
" the :edit below fires FileType autocommands for the target buffer while this
" function is still executing, re-sourcing this file — unguarded that's E127.
if !exists('*s:FollowLink')
function s:FollowLink() abort
  let l:line = getline('.')
  let l:col = col('.') - 1  " match() offsets are 0-based
  let l:idx = 0
  while 1
    let l:s = match(l:line, '\[[^]]*\]([^)]*)', l:idx)
    if l:s < 0
      echomsg 'Not on a link.'
      return
    endif
    let l:e = matchend(l:line, '\[[^]]*\]([^)]*)', l:idx)
    if l:col < l:s || l:col >= l:e
      let l:idx = l:e
      continue
    endif
    let l:target = matchlist(l:line[l:s : l:e - 1], '^\[[^]]*\](\(.*\))$')[1]
    if l:target =~# '^\a\+://'
      echomsg 'Refusing to leave the editor for: ' . l:target
      return
    endif
    execute 'edit' fnameescape(expand('%:h') . '/' . substitute(l:target, '#.*', '', ''))
    return
  endwhile
endfunction
endif
nmap <buffer> gd <Plug>(MdFollowLink)
nmap <buffer> gD <Plug>(MdFollowLink)
" <Cmd> runs without entering cmdline mode: cursor position survives untouched
nnoremap <buffer> <silent> <Plug>(MdFollowLink) <Cmd>call <SID>FollowLink()<CR>
