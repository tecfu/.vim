set nocompatible
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
let s:home = tempname() . ' home'
let s:original_home = $HOME
let s:original_profile = $VIM_PROFILE
let s:original_xdg = $XDG_CONFIG_HOME
let s:original_shell = [&shell, &shellcmdflag, &shellxquote]

try
  call mkdir(s:home . '/.vim/autoload', 'p')
  call writefile([], s:home . '/.vim/autoload/plug.vim')
  for s:config in ['config-vim.vim', 'config-nvim.vim']
    call writefile(['let g:compatible_at_plugin_load = &compatible'],
          \ s:home . '/.vim/' . s:config)
  endfor
  let $HOME = s:home
  unlet $VIM_PROFILE
  if !has('nvim')
    set compatible
  endif
  execute 'source' fnameescape(s:root . '/.vimrc')
  call assert_equal(0, g:compatible_at_plugin_load)
  call assert_equal(s:original_shell, [&shell, &shellcmdflag, &shellxquote])

  call writefile(['let g:init_loaded = 1'], s:home . '/.vimrc')
  if has('win32') || has('win64')
    let $HOME = substitute(substitute(s:home, '\\', '/', 'g'), '^\(\a\):/', '/\1/', '')
  endif
  execute 'source' fnameescape(s:root . '/init.vim')
  call assert_equal(1, g:init_loaded)
  if has('win32') || has('win64')
    call assert_match('^\a:/', $HOME)
  endif

  execute 'set runtimepath^=' . escape(s:root, ' ,')
  let g:git_bash = exepath('bash')
  call assert_false(empty(g:git_bash), 'bash is required for terminal regression')
  call vimrc#bash('printf ''%s\n'' ''literal $HOME & spaces''')
  let s:buffer = bufnr()
  if has('nvim')
    call assert_equal([0], jobwait([b:terminal_job_id], 5000))
    call assert_match('literal \$HOME & spaces', join(getbufline(s:buffer, 1, '$'), "\n"))
  else
    let s:job = term_getjob(s:buffer)
    for s:attempt in range(100)
      call term_wait(s:buffer, 50)
      if job_status(s:job) ==# 'dead'
        break
      endif
    endfor
    call assert_equal('dead', job_status(s:job))
    call assert_equal(0, job_info(s:job).exitval)
    call assert_match('literal \$HOME & spaces', term_getline(s:buffer, 1))
  endif
  call assert_equal(s:original_shell, [&shell, &shellcmdflag, &shellxquote])

  execute 'source' fnameescape(s:root . '/plugin/helpers.vim')
  new
  call setline(1, ['{', '  "message": "quoted \"text\" and \\path"', '}'])
  StringifyJSON
  call assert_equal(1, line('$'))
  call assert_equal({'message': 'quoted "text" and \path'}, json_decode(json_decode(getline(1))))
  call setline(1, '"a string"')
  StringifyJSON
  call assert_equal('a string', json_decode(getline(1)))
  call setline(1, ['before', '[1,true,null]', 'after'])
  2StringifyJSON
  call assert_equal('before', getline(1))
  call assert_equal([1, v:true, v:null], json_decode(json_decode(getline(2))))
  call assert_equal('after', getline(3))
  call setline(1, '{"decimal":1.23456789012345,"integer":9223372036854775808}')
  1StringifyJSON
  call assert_equal('{"decimal":1.23456789012345,"integer":9223372036854775808}', json_decode(getline(1)))

  let $XDG_CONFIG_HOME = s:home . '/config'
  execute 'source' fnameescape(s:root . '/plugin/sessions.vim')
  let s:expected_undo = has('nvim') ? stdpath('config') . '/undo' : expand('$HOME/.vim/undo')
  call assert_equal(s:expected_undo, &undodir)
  call assert_true(isdirectory(&undodir))
  if has('nvim')
    call mkdir(expand('$HOME/.config/nvim/undo'), 'p')
    execute 'source' fnameescape(s:root . '/plugin/sessions.vim')
    call assert_equal(expand('$HOME/.config/nvim/undo'), &undodir)
  endif
finally
  let $HOME = s:original_home
  let $VIM_PROFILE = s:original_profile
  let $XDG_CONFIG_HOME = s:original_xdg
  call delete(s:home, 'rf')
endtry

if !empty(v:errors)
  for s:error in v:errors
    echom s:error
  endfor
  cquit
endif
qall!
