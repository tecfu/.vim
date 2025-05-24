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
" Map <leader>l to the FormatCodeBlockOrFile function
augroup CustomCocMappings
  autocmd!
  autocmd FileType * nmap <silent> <leader>l :call FormatCodeBlockOrFile()<CR>
augroup end

" Logging helper function
function! LogDebug(message)
  " Normalize NVIM_LOG_LEVEL to lowercase for case-insensitive comparison
  let l:log_level = tolower($NVIM_LOG_LEVEL)
  if l:log_level == "debug"
    echom a:message
  endif
endfunction

" Format current buffer
function! FormatCodeBlockOrFile()
  let l:function_name = 'FormatCodeBlockOrFile: '
  call LogDebug(l:function_name . ":Start")

  if &filetype == 'markdown'

    call LogDebug(l:function_name . "Detected " . &filetype)

    " Check if the cursor is inside a code block
    " Search for the start of the named code block (with language), ensuring there is a string after the backticks
    let l:start = search('```', 'bnW')  " Search backwards from the cursor position
    if l:start == 0
      call LogDebug(l:function_name . "Could not find code block start.")
      return
    endif

    " Check if there is a language identifier (string) after the opening backticks
    let l:first_line = getline(l:start)
    let l:lang = matchstr(l:first_line, '^\s*```\zs\w\+\ze')

    if l:lang == ''
      call LogDebug(l:function_name . "No named code block detected, using default coc-nvim formatter.")
      call CocAction('format')
      return
    endif

    call LogDebug(l:function_name . "Detected named codeblock with language: " . l:lang)

    " Find the end of the code block by searching forward
    let l:end = search('```', 'nW')  " Search forwards from the start to find the end of the block

    if l:end == 0
      call LogDebug(l:function_name . "Could not find code block end.")
      return
    endif

    " Extract the lines of the code block (ignoring the backticks)
    let l:lines = getline(l:start + 1, l:end - 1)
    let l:formatted_lines = []

    " Log the lines being sent to the formatter
    call LogDebug(l:function_name . "Sending the following to formatter:")
    call LogDebug('---')
    call LogDebug(join(l:lines, "\n"))
    call LogDebug('---')

    " Define the map of languages to formatter commands
    " Key is the language, value is the command to run for formatting
     " let l:formatter_map = {
     " \ 'json': 'python3 -m json.tool',
     " \ 'javascript': 'prettier --parser babel',
     " \ 'js': 'prettier --parser babel',
     " \ 'typescript': 'prettier --parser typescript',
     " \ 'ts': 'prettier --parser typescript'
     " \ }

     let l:formatter_map = {}

    " Check if the language is in the formatter map and run the appropriate command
    if has_key(l:formatter_map, l:lang)
      let l:cmd = l:formatter_map[l:lang]
      call LogDebug(l:function_name . "Formatting [COC OVERRIDE] " . l:lang . " code block using '" . l:cmd . "'.")
      let l:formatted_lines = systemlist(l:cmd, join(l:lines, "\n"))
    else
      call LogDebug(l:function_name . "Formatting using coc-nvim default " . l:lang)
      call CocAction('format')
      return
    endif

    " Check if there was an error formatting the code
    if v:shell_error != 0
      let l:error_message = join(l:formatted_lines, "\n")
      call LogDebug(l:function_name . "Error formatting code block.")
      call LogDebug('---')
      call LogDebug(l:error_message)
      call LogDebug('---')
      return
    endif

    " Include backticks to the formatted lines
    let l:formatted_lines_with_backticks = ['```' . l:lang] + l:formatted_lines + ['```']

    " Replace the code block with the formatted lines, including backticks
    call setline(l:start, l:formatted_lines_with_backticks)

    call LogDebug(l:function_name . "Code block formatted successfully.")
  else
    " Not in a markdown file, use default formatting
    call CocAction('format')
    call LogDebug(l:function_name . "Formatted " . &filetype)
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
" 1. If Copilot ghost text is visible, accept Copilot suggestion.
" 2. Else, if CoC popup menu is visible, confirm the highlighted CoC item.
" 3. Else, if at start of line or after whitespace, insert a literal Tab.
" 4. Else, try to trigger CoC completion/expansion.
inoremap <silent><expr> <Tab>
    \ luaeval('require("copilot.suggestion").is_visible()')
    \ ? luaeval('(function() require("copilot.suggestion").accept(); return "" end)()')
    \ : coc#pum#visible()
    \   ? coc#pum#confirm()
    \   : CheckBackspace()
    \     ? "\<Tab>"
    \     : coc#expandableOrJumpable()
    \       ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>"
    \       : coc#refresh()

"Remap up/down in popupmenu to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"Remap up/down in coc popup to <C-j>, <C-k>
inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
"}}}
