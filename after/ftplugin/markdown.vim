" Markdown: indentation, spell, fence-aware folding
setlocal shiftwidth=2 tabstop=2
setlocal spell
setlocal foldmethod=expr
setlocal foldexpr=MarkdownLevel()
setlocal foldlevel=1

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
