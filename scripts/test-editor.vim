set nocompatible
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'set runtimepath^=' . escape(s:root, ' ,')
let s:work = tempname() . ' editor fixtures'
let s:cwd = getcwd()
let s:pwd = $PWD
let s:display = $DISPLAY
let s:wayland = $WAYLAND_DISPLAY
let s:state = $XDG_STATE_HOME

function! s:Git(args) abort
  let l:output = system('git -C ' . shellescape(s:work) . ' ' . a:args)
  call assert_equal(0, v:shell_error, l:output)
  return trim(l:output)
endfunction

try
  call mkdir(s:work, 'p')
  execute 'source' fnameescape(s:root . '/plugin/helpers.vim')
  let $PWD = s:work
  doautocmd BufEnter COMMIT_EDITMSG
  call assert_equal(resolve(s:work), resolve(getcwd()))
  execute 'lcd' fnameescape(s:cwd)
  let $PWD = s:pwd

  let $DISPLAY = ''
  let $WAYLAND_DISPLAY = ''
  unlet! g:clipboard
  execute 'source' fnameescape(s:root . '/plugin/clipboard.vim')
  call assert_false(exists('g:clipboard'), 'Native provider detection must remain available')
  let g:clipboard = {'name': 'user override'}
  let $DISPLAY = ':0'
  let $WAYLAND_DISPLAY = 'wayland-0'
  execute 'source' fnameescape(s:root . '/plugin/clipboard.vim')
  call assert_equal({'name': 'user override'}, g:clipboard)
  unlet g:clipboard

  call s:Git('init -q')
  let s:file = s:work . '/-file with spaces.txt'
  call writefile(['first'], s:file)
  call s:Git('add -- ' . shellescape('-file with spaces.txt'))
  call s:Git('-c user.name=Fixture -c user.email=fixture@example.invalid commit -qm first')
  let s:first = s:Git('rev-parse HEAD')
  call writefile(['second'], s:file)
  call s:Git('add -- ' . shellescape('-file with spaces.txt'))
  call s:Git('-c user.name=Fixture -c user.email=fixture@example.invalid commit -qm second')
  let s:second = s:Git('rev-parse HEAD')
  execute 'noautocmd edit' fnameescape(s:file)
  command! -nargs=1 Gdiffsplit let g:diff_revision = <q-args>
  call vimrc#diffprev(0)
  call assert_equal(s:second, g:diff_revision)
  call vimrc#diffprev(1)
  call assert_equal(s:first, g:diff_revision)
  for s:revision in [-1, 99]
    try
      call vimrc#diffprev(s:revision)
      call assert_report('Invalid/missing revision was accepted')
    catch /Gdiffprev/
    endtry
  endfor

  if has('nvim')
    execute 'source' fnameescape(s:root . '/viml/nvim-lsp-diagnostic-window.nvim')
    lua << EOF
    local ns = vim.api.nvim_create_namespace('review-regression')
    local diagnostics = {}
    for severity = 1, 4 do
      table.insert(diagnostics, {
        lnum = 0, col = 0, severity = severity, source = 'fixture',
        message = 'severity ' .. severity,
      })
    end
    vim.diagnostic.set(ns, 0, diagnostics)
EOF
    call SetLocationList()
    call assert_equal(['E', 'H', 'I', 'W'], sort(map(getloclist(0), 'v:val.type')))
    call assert_equal(4, len(getloclist(0)))
    let $XDG_STATE_HOME = s:work . '/state'
    execute 'source' fnameescape(s:root . '/viml/nvim-lsp-efm.nvim')
    call assert_equal(stdpath('state') . '/efm-langserver.log', luaeval('vim.lsp.config.efm.cmd[5]'))
    call assert_true(isdirectory(stdpath('state')))
  endif
catch
  call assert_report(v:exception . ' at ' . v:throwpoint)
finally
  execute 'lcd' fnameescape(s:cwd)
  let $PWD = s:pwd
  let $DISPLAY = s:display
  let $WAYLAND_DISPLAY = s:wayland
  let $XDG_STATE_HOME = s:state
  bwipeout!
  call delete(s:work, 'rf')
endtry

if !empty(v:errors)
  for s:error in v:errors
    echom s:error
  endfor
  cquit
endif
qall!
