let g:coc_config_home = expand('$HOME/.vim')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" coc extensions
"
let g:coc_global_extensions = [
      \ 'coc-cfn-lint',
      \ 'coc-copilot',
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
"    \ '@hexuhua/coc-copilot',
"\ ]

call plug#end()

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


" Extension keybindings
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


" Coc keybindings

" CocDiagnotics
nnoremap <expr> <space>i
  \ (CheckLocationListOpen() ? ":CocDiagnostics" : ":lclose")."<CR>"

" Format current buffer
augroup CustomCocMappings
  autocmd!
  autocmd FileType * nmap <silent> <leader>l :call CocAction('format')<CR>
augroup end

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


"vmap <S-f>  <Plug>(coc-format-selected)
"run cmd on range of entire file
"nmap <S-f>  <Plug>(coc-format)%

"Coc Popup Completion settings
"Use <tab> for trigger completion and navigate to the next complete item
"Modified from docs due to error: https://github.com/neoclide/coc.nvim/issues/3167
inoremap <silent><expr> <Tab>
 \ pumvisible() ? "\<C-n>" :
 \ coc#expandableOrJumpable() ?
 \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<Tab>"

inoremap <silent><expr> <S-Tab>
 \ pumvisible() ? "\<C-p>" :
 \ coc#expandableOrJumpable() ?
 \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-pre',''])\<CR>" : "\<Tab>"

"Select the first completion item and confirm the completion when no item has been selected:
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

"Remap up/down in popupmenu to <C-j>, <C-k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"Remap up/down in coc popup to <C-j>, <C-k>
inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

function! CocPumMultipleTimes(action, count)
    let l:result = ''
    if a:action == 'next'
        let l:cmd = repeat("\<C-r>=coc#pum#_navigate(1,1)\<CR>", a:count)
    elseif a:action == 'prev'
        let l:cmd = repeat("\<C-r>=coc#pum#_navigate(0,0)\<CR>", a:count)
    else
        return ''
    endif
    return l:cmd
endfunction

" <C-s-j/k> supported by gvim
inoremap <expr><C-S-j> coc#pum#visible() ? CocPumMultipleTimes('next', 5) : "\<C-S-j>"
inoremap <expr><C-S-k> coc#pum#visible() ? CocPumMultipleTimes('prev', 5) : "\<C-S-k>"

"Scroll info popup
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"}}}
