let g:coc_config_home = expand('$HOME/.vim')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" coc extensions
"
" @todo change lsps to use efm langserver
let g:coc_global_extensions = [
      \ 'coc-cfn-lint',
      \ 'coc-eslint',
      \ 'coc-html',
      \ 'coc-markdownlint',
      \ 'coc-marketplace',
      \ 'coc-sh',
      \ 'coc-sql',
      \ 'coc-toml',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-yaml',
      \ '@hexuhua/coc-copilot',
      \ ]

"let g:coc_global_extensions = [
"    \ 'coc-copilot',
"    \ '@hexuhua/coc-copilot', " https://github.com/hexh250786313/coc-copilot
"\ ]

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
