set nomore
let s:failed = 0
try
  if !exists(':PlugInstall')
    throw 'PlugInstall is unavailable; configuration did not load successfully.'
  endif
  PlugInstall --sync
  let s:reports = filter(getbufinfo(), 'fnamemodify(v:val.name, ":t") =~# "^\\[Plugins\\]"')
  if empty(s:reports)
    throw 'vim-plug did not produce an installation report.'
  endif
  for s:report in s:reports
    for s:line in getbufline(s:report.bufnr, 1, '$')
      echom s:line
      if s:line =~# '^x '
        let s:failed = 1
      endif
    endfor
  endfor
catch
  echom 'Plugin installation failed: ' . v:exception
  let s:failed = 1
endtry
if s:failed
  cquit
endif
qall!
