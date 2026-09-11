function! vimrc#bash(command) abort
  if !executable(get(g:, 'git_bash', ''))
    echoerr 'Git Bash is unavailable.'
    return
  endif

  " An argv list bypasses the native shell's quoting, including paths with spaces.
  let l:argv = empty(a:command)
        \ ? [g:git_bash, '-l']
        \ : [g:git_bash, '-c', a:command]
  if has('nvim')
    new
    let l:job = termopen(l:argv)
    if l:job <= 0
      echoerr 'Failed to start Git Bash.'
    else
      startinsert
    endif
  elseif has('terminal')
    if term_start(l:argv) == 0
      echoerr 'Failed to start Git Bash.'
    endif
  else
    echoerr 'This Vim build does not support terminals.'
  endif
endfunction
