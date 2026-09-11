set nocompatible
set nomore
set hidden
let g:test_plug_declarations = 0
let g:test_plug_loads = []
let g:test_coc_config = {}
let s:root = $VIM_TEST_ROOT
let s:home = expand('$HOME/.vim')
let s:mode = empty($NVIM_CONFIG) ? 'cmp-builtin' : $NVIM_CONFIG

try
  call assert_true(isdirectory(s:home), 'Run through scripts/run-editor-tests.py')
  execute 'set runtimepath^=' . escape(s:home, ' ,')
  let g:coc_data_home = $VIM_TEST_WORK . '/coc-data'
  if has('nvim')
    execute 'luafile' fnameescape(s:root . '/scripts/test-modes.lua')
  endif
  execute 'source' fnameescape(s:root . '/.vimrc')
  call assert_equal(s:mode, g:nvim_config)
  call assert_true(g:test_plug_declarations > 0, 'Real plugin declarations were evaluated')
  filetype plugin indent on
  doautocmd VimEnter

  if s:mode ==# 'coc'
    doautocmd User CocNvimInit
    let s:registry = json_decode(join(readfile(s:home . '/lsp-servers.json'), "\n"))
    call assert_equal(len(s:registry.servers), len(g:test_coc_config))
    for s:server in s:registry.servers
      let s:actual = g:test_coc_config['languageserver.' . s:server.name]
      call assert_equal(s:server.cmd[0], s:actual.command)
      call assert_equal(s:server.cmd[1:], s:actual.args)
      call assert_equal(s:server.filetypes, s:actual.filetypes)
      call assert_equal(get(s:server, 'settings', {}), get(s:actual, 'settings', {}))
    endfor
    call assert_equal(0, exists('*SetupLspBuiltin'))
    call assert_equal(0, exists('*SetupCmp'))
    call assert_equal('<Plug>(coc-diagnostic-next)', maparg(']g', 'n'))
    for s:language in ['python', 'go']
      let s:extension = s:language ==# 'python' ? 'py' : 'go'
      execute 'edit' fnameescape($VIM_TEST_PROJECT . '/example.' . s:extension)
      call assert_equal(s:language, &filetype)
      call assert_match("CocAction('format')", maparg('\l', 'n'))
    endfor
    if has('nvim')
      lua assert(#vim.lsp.get_clients() == 0, 'CoC must not start native LSP clients')
    endif
  else
    call assert_equal({}, g:test_coc_config)
    lua ModeTests.run()
  endif
catch
  call assert_report(v:exception . ' at ' . v:throwpoint)
finally
  if has('nvim')
    lua for _, client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
  endif
endtry

if !empty(v:errors)
  for s:error in v:errors
    echom s:error
  endfor
  cquit
endif
qall!
