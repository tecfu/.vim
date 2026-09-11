" Markdown: indentation, spell, fence-aware folding
setlocal shiftwidth=2 tabstop=2
setlocal spell
setlocal foldmethod=expr
setlocal foldexpr=markdownfold#Level(v:lnum)
setlocal foldlevel=1
