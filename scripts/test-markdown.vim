set nocompatible
set nomore
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
enew
execute 'source ' . fnameescape(s:root . '/after/ftplugin/markdown.vim')

function! s:Check(lines, expected) abort
  silent %delete _
  call setline(1, a:lines)
  for position in [1, len(a:lines), max([1, len(a:lines) / 2])]
    call cursor(position, 1)
    let view = winsaveview()
    let actual = map(range(1, len(a:lines)), 'markdownfold#Level(v:val)')
    call assert_equal(a:expected, actual, 'cursor at ' . position)
    call assert_equal(view, winsaveview(), 'foldexpr changed window/cursor')
  endfor
endfunction

call assert_equal(2, &l:shiftwidth)
call assert_equal(2, &l:tabstop)
call assert_true(&l:spell)
call assert_equal('expr', &l:foldmethod)
call assert_equal(1, &l:foldlevel)

call s:Check(
      \ ['# One', 'body', '## Two', '### Three', '#### Four', '##### Five',
      \ '###### Six', '####### Invalid', '#not heading', '#', '  ##',
      \ "   ###\tTabbed", '    # Indented', 'Setext one', ' ===  ',
      \ 'Setext two', '---', 'tail'],
      \ ['>1', '=', '>2', '>3', '>4', '>5', '>6', '=', '=', '>1', '>2',
      \ '>3', '=', '>1', '=', '>2', '=', '='])

for s:kind in ['`', '~']
  let s:fence = repeat(s:kind, 4)
  let s:other = s:kind == '`' ? '~~~~' : '````'
  call s:Check(
        \ ['# Top', '   ' . s:fence . ' lang', '# Hidden', 'Setext hidden',
        \ '===', repeat(s:kind, 3), '## Still hidden', s:other,
        \ '### Still hidden', s:fence . ' not a close', '# Hidden too',
        \ '    ' . s:fence, '# Indented close ignored',
        \ '  ' . s:fence . s:kind . '  ', '## Visible'],
        \ ['>1', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=',
        \ '=', '=', '>2'])
  call s:Check(
        \ ['# Top', repeat(s:kind, 3), '# Hidden', 'Title', '---'],
        \ ['>1', '=', '=', '=', '='])
endfor

call s:Check(
      \ ['    ```', '# Visible', '```bad`info', '## Also visible',
      \ '```', '# Hidden', '```', 'Title', '---', '---', 'tail'],
      \ ['=', '>1', '=', '>2', '=', '=', '=', '>2', '=', '=', '='])
call s:Check(
      \ ['---', '===', '***', '---', '___', '===', '#text', '---',
      \ '####### text', '===', '    indented', '---', '> quote', '---',
      \ '- list', '---', '', '==='],
      \ ['=', '=', '=', '=', '=', '=', '>2', '=', '>1', '=', '=', '=',
      \ '=', '=', '=', '=', '=', '='])
call s:Check(['# Original', 'text', '## Nested'], ['>1', '=', '>2'])
let s:old_tick = b:markdownfold_tick
call setline(1, '### Changed')
call assert_equal('>3', markdownfold#Level(1))
call assert_notequal(s:old_tick, b:markdownfold_tick)
let s:cache = b:markdownfold_levels
call markdownfold#Level(3)
call assert_true(s:cache is b:markdownfold_levels, 'cache rebuilt without an edit')
call setline(2, '~~~')
call assert_equal('=', markdownfold#Level(3), 'fence edit did not invalidate cache')

call s:Check(['# Top', 'text', '## Child', 'text'], ['>1', '=', '>2', '='])
normal! zx
call assert_equal([1, 1, 2, 2], map(range(1, 4), 'foldlevel(v:val)'))

if !empty(v:errors)
  for s:error in v:errors
    echomsg s:error
  endfor
  cquit
endif
qa!
