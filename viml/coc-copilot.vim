Plug 'github/copilot.vim'

let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <TAB> copilot#Accept("\<CR>")

if has('nvim')
Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }

function! SetupChat()
  lua << EOF
  require('CopilotChat').setup({
    debug = true,
    -- mappings = {
    --   complete = {
    --     detail = 'Use @<Tab> or /<Tab> for options.',
    --     -- Default <Tab> setting conflicts with cmp and coc-nvim
    --     insert = '<S-Tab>'
    --   }
    -- }
  })
EOF
endfunction
autocmd VimEnter * call SetupChat()

" Optional: Add a keybinding to open the chat window
nnoremap <C-M-i> :CopilotChatToggle<CR>
vnoremap <C-M-f> :CopilotChatFix<CR>
endif
