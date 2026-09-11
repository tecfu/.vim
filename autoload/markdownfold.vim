function! markdownfold#Level(lnum) abort
  if !exists('b:markdownfold_tick') || b:markdownfold_tick != b:changedtick
    let lines = getline(1, '$')
    let levels = repeat(['='], len(lines))
    let fence = ''
    let fence_length = 0
    let i = 0
    while i < len(lines)
      let text = lines[i]
      let marker = matchstr(text, '^ \{0,3}\zs\(`\{3,}\|\~\{3,}\)')
      if !empty(fence)
        if !empty(marker) && marker[0] == fence && len(marker) >= fence_length
              \ && text =~ '^ \{0,3}' . escape(marker, '~') . '[ \t]*$'
          let fence = ''
        endif
      elseif !empty(marker) && (marker[0] != '`'
            \ || strpart(text, matchend(text, '^ \{0,3}`\{3,}')) !~ '`')
        let fence = marker[0]
        let fence_length = len(marker)
      else
        let heading = matchstr(text, '^ \{0,3}\zs#\{1,6}\ze\([ \t]\|$\)')
        if !empty(heading)
          let levels[i] = '>' . len(heading)
        elseif i + 1 < len(lines) && text =~ '^ \{0,3}\S'
              \ && text !~ '^ \{0,3}\(>\|[-+*][ \t]\|[0-9]\+[.)][ \t]\)'
              \ && text !~ '^ \{0,3}\([-*_]\)[ \t]*\1[ \t]*\1\%([ \t]*\1\)*[ \t]*$'
          let underline = matchstr(lines[i + 1], '^ \{0,3}\zs\(=\+\|-\+\)\ze[ \t]*$')
          if !empty(underline)
            let levels[i] = underline[0] == '=' ? '>1' : '>2'
            let i += 1
          endif
        endif
      endif
      let i += 1
    endwhile
    let b:markdownfold_levels = levels
    let b:markdownfold_tick = b:changedtick
  endif
  return get(b:markdownfold_levels, a:lnum - 1, '=')
endfunction
