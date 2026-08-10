function! HasWSL() abort
  if has('win32') || has('win64')
    " Check if wsl.exe is in the PATH or in a standard system location.
    " This is a common indicator of WSL being installed and available.
    if executable('wsl.exe')
      return 1
    else
      return 0
    endif
  endif
  " Not on Windows, so WSL is not relevant in the context of this check
  return 0
endfunction

" Determine CoC profile, default to 'default' if not set by .vimrc
" Check if $COC_PROFILE is empty
if empty($COC_PROFILE)
  let g:coc_profile = "default"
else
  let g:coc_profile = $COC_PROFILE
endif

let g:coc_profile_dir = expand('$HOME/.vim/coc-profiles/') . g:coc_profile

" Set coc_config_home to the profile directory. CoC will look for coc-settings.json here.
let g:coc_config_home = g:coc_profile_dir

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Load extensions from extensions.json if it exists
let s:extensions_json_path = g:coc_profile_dir . '/extensions.json'
if filereadable(s:extensions_json_path)
  let s:loaded_extensions = json_decode(join(readfile(s:extensions_json_path), "\n"))
else
  " Fallback to a minimal set of extensions if file doesn't exist
  let s:loaded_extensions = ['coc-marketplace', '@hexuhua/coc-copilot']
endif

" Load unix-only extensions if on Linux (excluding Git Bash/Cygwin) or WSL
let s:is_unix_or_wsl = (has('unix') && !has('win32unix')) || HasWSL()
let s:extensions_unix_json_path = g:coc_profile_dir . '/extensions-unix.json'

if s:is_unix_or_wsl
  if filereadable(s:extensions_unix_json_path)
    let s:unix_extensions = json_decode(join(readfile(s:extensions_unix_json_path), "\n"))
    call extend(s:loaded_extensions, s:unix_extensions)
  endif
endif

let g:coc_global_extensions = s:loaded_extensions

" Sync extensions: Remove extensions from filesystem that are not in g:coc_global_extensions
" This runs immediately to ensure clean state before Coc starts
function! s:SyncExtensionsFilesystem() abort
  " Determine coc data home
  let l:coc_data_home = get(g:, 'coc_data_home', '')
  if empty(l:coc_data_home)
    if has('win32') || has('win64')
      let l:coc_data_home = '~/AppData/Local/coc'
    elseif has('win32unix') " Git Bash
      let l:coc_data_home = '~/AppData/Local/coc'
    else
      let l:coc_data_home = '~/.config/coc'
    endif
  endif
  
  " Check both standard node_modules location and direct extensions folder
  let l:roots = [
        \ expand(l:coc_data_home . '/extensions/node_modules'),
        \ expand(l:coc_data_home . '/extensions')
        \ ]
  
  let l:allowed_extensions = g:coc_global_extensions
  
  for l:root in l:roots
    if !isdirectory(l:root)
      continue
    endif

    let l:installed_dirs = glob(l:root . '/*', 1, 1)
    
    for l:dir in l:installed_dirs
      let l:name = fnamemodify(l:dir, ':t')
      
      " Skip if it's not a directory
      if !isdirectory(l:dir)
        continue
      endif

      " Skip system directories/files in extensions folder
      if l:name ==# 'node_modules' || l:name ==# '.cache'
        continue
      endif

      if l:name =~# '^@'
        " Scoped package, check subdirectories
        let l:subdirs = glob(l:dir . '/*', 1, 1)
        for l:subdir in l:subdirs
          let l:subname = fnamemodify(l:subdir, ':t')
          let l:full_name = l:name . '/' . l:subname
          if index(l:allowed_extensions, l:full_name) == -1
             call system('rm -rf ' . shellescape(l:subdir))
          endif
        endfor
        " Remove scope dir if empty
        if empty(glob(l:dir . '/*', 1, 1))
           call system('rm -rf ' . shellescape(l:dir))
        endif
      else
        " Normal package
        if index(l:allowed_extensions, l:name) == -1
           call system('rm -rf ' . shellescape(l:dir))
        endif
      endif
    endfor
  endfor
endfunction

call s:SyncExtensionsFilesystem()

" --- Shared LSP Server Registry ---
" Servers are defined once in ~/.vim/lsp-servers.json and shared with the
" cmp/native-LSP flow (see viml/nvim-lsp-builtin.nvim) so server
" cmd/filetypes/settings aren't duplicated across coc profiles. Pure
" lint/format-only tools that require efm-langserver stay defined directly
" in each profile's coc-settings.json (efm-specific).

" Auto-install a missing server binary using its `install` command from
" lsp-servers.json, asynchronously so nvim/vim startup isn't blocked.
" Cross-compatible with both vim8 (job_start) and Neovim (jobstart).
let s:installing_servers = {}
function! s:OnInstallServerExit(name, bin, cmd, code) abort
  " Exit code 0 only means the install command ran without error; it
  " doesn't guarantee the binary is now reachable (PATH may not be
  " refreshed for this process, or the command may have silently
  " targeted the wrong Python/Node install). Re-check before claiming
  " success so the message isn't misleading.
  if a:code == 0 && executable(a:bin)
    echom "Installed LSP server '" . a:name . "'. Restart to use it."
  elseif a:code == 0
    echom "WARNING: Ran install command for '" . a:name . "', but '" . a:bin .
          \ "' is still not executable. The install may have targeted the wrong " .
          \ "environment, or its install directory may not be on PATH: " . a:cmd
  else
    echom "WARNING: Failed to install '" . a:name . "' (exit " . a:code . "): " . a:cmd
  endif
endfunction

" Wrap the install string in a native shell invocation rather than a plain
" argv split: on Windows, tools like npm/go are ".cmd"/".bat" shims that
" can't be spawned directly, and relying on the user's own 'shell' option
" is unsafe (it may be overridden to a path containing spaces, e.g. Git
" Bash). Using cmd.exe/sh directly sidesteps both problems on each OS.
function! s:ShellWrapArgv(cmd) abort
  if has('win32') || has('win64')
    return ['cmd.exe', '/c', a:cmd]
  else
    return ['/bin/sh', '-c', a:cmd]
  endif
endfunction

function! s:InstallServerAsync(name, bin, cmd) abort
  if has_key(s:installing_servers, a:name)
    return
  endif
  let s:installing_servers[a:name] = 1
  echom "Installing missing LSP server '" . a:name . "': " . a:cmd
  let l:argv = s:ShellWrapArgv(a:cmd)
  if has('nvim')
    call jobstart(l:argv, {
          \ 'on_exit': {job_id, code, event -> s:OnInstallServerExit(a:name, a:bin, a:cmd, code)}
          \ })
  else
    call job_start(l:argv, {
          \ 'exit_cb': {job, code -> s:OnInstallServerExit(a:name, a:bin, a:cmd, code)}
          \ })
  endif
endfunction

function! s:RegisterSharedLspServers() abort
  let l:json_path = expand('$HOME/.vim/lsp-servers.json')
  if !filereadable(l:json_path)
    return
  endif

  let l:decoded = json_decode(join(readfile(l:json_path), "\n"))
  for l:server in get(l:decoded, 'servers', [])
    if !executable(l:server.cmd[0]) && has_key(l:server, 'install')
      call s:InstallServerAsync(l:server.name, l:server.cmd[0], l:server.install)
    endif

    let l:entry = {
          \ 'filetypes': l:server.filetypes,
          \ 'command': l:server.cmd[0],
          \ 'args': l:server.cmd[1:],
          \ 'rootPatterns': get(l:server, 'root_patterns', ['.git/']),
          \ }
    if has_key(l:server, 'settings')
      let l:entry.settings = l:server.settings
    endif
    call coc#config('languageserver.' . l:server.name, l:entry)
  endfor
endfunction

augroup SharedLspServers
  autocmd!
  autocmd User CocNvimInit call s:RegisterSharedLspServers()
augroup END

" Function to disable coc-yaml for specific files
"function! DisableCocYamlForCF()
"  if search('AWSTemplateFormatVersion', 'nw')
"    " Delay the execution to ensure coc.nvim is ready
"    call timer_start(2000, { -> CocAction('deactivateExtension', 'coc-yaml') })
"  endif
"endfunction

" Autocommand to trigger the function
"augroup DisableCocYamlForCF
"  autocmd!
"  autocmd BufRead,BufNewFile *.yaml call DisableCocYamlForCF()
"augroup END


" Coc keybindings
" Map <leader>l to call CocAction('format')
" We previously use a special function to do this see: commit a09c80, but it is now handled by https://github.com/eslint/eslint-plugin-markdown in .eslintrc.js
"module.exports = {
"    extends: "plugin:markdown/recommended"
"};
augroup CustomCocMappings
  autocmd!
  autocmd FileType * nmap <silent> <leader>l :call CocAction('format') <CR>
augroup end

" Logging helper function
function! LogDebug(message)
  " Normalize NVIM_LOG_LEVEL to lowercase for case-insensitive comparison
  let l:log_level = tolower($NVIM_LOG_LEVEL)
  if l:log_level == "debug"
    echom a:message
  endif
endfunction

" view available code actions
nmap <leader>d  <Plug>(coc-codeaction)
nmap <leader>fc <Plug>(coc-fix-current)
nmap <silent> gD <Plug>(coc-definition)
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use to show documentation in preview window
" nmap <silent> gk <Plug>(coc-hover)

" coc-explorer
nmap <space>e <Cmd>CocCommand explorer<CR>

" CocDiagnostics
nnoremap <expr> <space>i
  \ (CheckLocationListOpen() ? ":CocDiagnostics" : ":lclose")."<CR>"

" Fix diagnostics popup background color
function! CheckLocationListOpen()
  if get(getloclist(0, {'winid':0}), 'winid', 0)
      " the location window is closed
      return 0
  else
      " the location window is open
      return 1
  endif
endfunction

" Coc Popup Completion settings
" Use <tab> for trigger completion and navigate to the next complete item
" Modified from docs due to error: https://github.com/neoclide/coc.nvim/issues/3167
"inoremap <silent><expr> <Tab>
" \ pumvisible() ? coc#pum#confirm() :
" \ coc#expandableOrJumpable() ?
" \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<Tab>"
"
"inoremap <silent><expr> <S-Tab>
" \ pumvisible() ? "\<C-p>" :
" \ coc#expandableOrJumpable() ?
" \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-pre',''])\<CR>" : "\<Tab>"
"
" Select the first completion item and confirm the completion when no item has been selected:
"inoremap <silent><expr> <CR> 
"\ copilot#Accept("\<CR>") ? copilot#Accept("\<CR>") :
"\ pumvisible() ? coc#_select_confirm() :
"\ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" <CR> mapping:
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

" <Tab> mapping:
" Priority:
" 1. Try to accept copilot.lua suggestion if visible.
" 2. Else, try to accept github/copilot.vim suggestion if visible.
" 3. Else, CoC popup menu.
" 4. Else, literal Tab if at start of line/after whitespace.
" 5. Else, CoC snippet expansion.
" 6. Else, CoC refresh.
inoremap <silent><expr> <Tab>
    \ TabCompletion_CopilotLuaIsVisible() ? TabCompletion_AcceptCopilotLua() :
    \ TabCompletion_CopilotVimIsVisible() ? TabCompletion_AcceptCopilotVim() :
    \ coc#pum#visible() ? coc#pum#confirm() :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#expandableOrJumpable() ?
    \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ coc#refresh()

"Remap up/down in popupmenu to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"Remap up/down in coc popup to <C-j>, <C-k>
inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
"}}}
