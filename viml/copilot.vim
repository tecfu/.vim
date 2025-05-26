" Used ONLY with coc-nvim
" This plugin produces "ghost text" suggestions using GitHub Copilot, whereas
" nvim-cmp, coc.nvim and others handle to popup menu completion sources.
Plug 'github/copilot.vim'

" Disable Copilot for all files containing *.pvt.*
autocmd BufRead,BufNewFile *.pvt.* let b:copilot_enabled = 0

" Use default <Tab> to accept a suggestion
" let g:copilot_no_tab_map = v:false
" We switch this to true so that our autocompletion (i.e. coc, nvim-cmp) plugin can handle the <Tab> key exclusively
let g:copilot_no_tab_map = v:true

" Accept next word on C-Enter
" Note: vim can't handle this key combination, nvim can
imap <silent><expr> <C-Enter> copilot#AcceptWord()

" <Tab> is the default keymap for accepting a suggestion, here's an example of rempping it to <C-j>
" imap <silent><script><expr> <CR> copilot#AcceptWord("\<CR>")


" <M-Right>               Accept the next word of the current suggestion.
" <Plug>(copilot-accept-word)
"
"
" <C-]>                   Dismiss the current suggestion.
" <Plug>(copilot-dismiss)
" 
"                                                 *copilot-i_ALT-]*
" <M-]>                   Cycle to the next suggestion, if one is available.
" <Plug>(copilot-next)
" 
"                                                 *copilot-i_ALT-[*
" <M-[>                   Cycle to the previous suggestion.
" <Plug>(copilot-previous)
" 
"                                                 *copilot-i_ALT-\*
" <M-\>                   Explicitly request a suggestion, even if Copilot
" <Plug>(copilot-suggest) is disabled.
" 
"                                                 *copilot-i_ALT-Right*
" <M-Right>               Accept the next word of the current suggestion.
" <Plug>(copilot-accept-word)
" 
"                                                 *copilot-i_ALT-CTRL-Right*
" 
" <M-C-Right>             Accept the next line of the current suggestion.
" <Plug>(copilot-accept-line)

