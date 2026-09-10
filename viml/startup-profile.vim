"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Startup Profiling
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Always profile startup and print a summary to :messages once VimEnter
" fires, so slow plugins/autocmds can be diagnosed at any time by simply
" running `:messages` -- no need to remember to relaunch with
" `--startuptime` or manually run `:profile`.
"
" This must be the very first thing in .vimrc so it captures everything
" sourced afterwards (config-vim.vim/config-nvim.vim, all plugins, etc).
" Profiling is paused right after the summary is printed so it doesn't add
" ongoing per-call overhead for the rest of the editing session.
if has('profile') && !exists('g:startup_profile_log')
  let g:startup_profile_log = expand('$HOME/.vim/.startup-profile.log')
  let g:startup_profile_start = reltime()
  execute 'profile start ' . fnameescape(g:startup_profile_log)
  profile file *
  profile func *
endif

" Parse the "SCRIPT <path>" blocks that `profile file *` writes and return
" a list of [self_seconds, path] sorted slowest-first. Vim doesn't generate
" a ready-made sorted summary for scripts (only for functions via
" "FUNCTIONS SORTED ON SELF TIME"), so aggregate it ourselves.
function! s:ParseProfileScripts(lines) abort
  let l:scripts = []
  let l:i = 0
  while l:i < len(a:lines)
    if a:lines[l:i] =~# '^SCRIPT\s'
      let l:path = substitute(a:lines[l:i], '^SCRIPT\s\+', '', '')
      " Self time is always 3 lines below the "SCRIPT <path>" header:
      "   SCRIPT <path> / Sourced N time(s) / Total time: X / Self time: X
      if l:i + 3 < len(a:lines) && a:lines[l:i + 3] =~# 'Self time:'
        let l:self = str2float(matchstr(a:lines[l:i + 3], '[0-9.]\+'))
        call add(l:scripts, [l:self, l:path])
      endif
    endif
    let l:i += 1
  endwhile
  call sort(l:scripts, {a, b -> a[0] == b[0] ? 0 : (a[0] < b[0] ? 1 : -1)})
  return l:scripts
endfunction

function! s:ShowStartupProfile() abort
  if !exists('g:startup_profile_log') | return | endif

  try
    let l:total_ms = reltimefloat(reltime(g:startup_profile_start)) * 1000

    " Stop capturing further overhead now that startup has finished.
    profile pause

    echom '================ Vim Startup Profile ================'
    echom printf('Total startup time: %.1f ms', l:total_ms)

    if filereadable(g:startup_profile_log)
      let l:lines = readfile(g:startup_profile_log)

      let l:scripts = s:ParseProfileScripts(l:lines)
      echom '--- Slowest scripts (self time) ---'
      for [l:self, l:path] in l:scripts[0 : 11]
        if l:self <= 0.0001 | continue | endif
        echom printf('%7.1fms  %s', l:self * 1000, l:path)
      endfor

      let l:fidx = index(l:lines, 'FUNCTIONS SORTED ON SELF TIME')
      if l:fidx >= 0
        echom '--- Slowest functions (self time) ---'
        let l:shown = 0
        for l:line in l:lines[(l:fidx + 2) :]
          if empty(trim(l:line)) | break | endif
          echom l:line
          let l:shown += 1
          if l:shown >= 12 | break | endif
        endfor
      endif
    endif

    echom printf('Full detail: %s', g:startup_profile_log)
    echom '======================================================='
  catch
    echom 'Startup profile error: ' . v:exception
  endtry
endfunction

augroup StartupProfiling
  autocmd!
  autocmd VimEnter * call s:ShowStartupProfile()
augroup END
"}}}

