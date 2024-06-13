Plug 'github/copilot.vim'

if has('nvim')
  Plug 'zbirenbaum/copilot.lua'
  autocmd VimEnter * call luaeval("require('copilot').setup()")

  if $NVIM_CONFIG == 'cmp'
    Plug 'zbirenbaum/copilot-cmp'
    autocmd VimEnter * call luaeval("require('copilot_cmp').setup()")
  endif
endif

Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
function! SetupCopilotChat()
lua << EOF
require('CopilotChat').setup({
  debug = true,
  mappings = {
    complete = {
      detail = 'Use @<Tab> or /<Tab> for options.',
      -- Default <Tab> setting conflicts with cmp and coc-nvim
      insert = '<S-Tab>'
    }
  }
})
EOF
endfunction
autocmd VimEnter * call SetupCopilotChat()

" Optional: Add a keybinding to open the chat window
nnoremap <C-M-i> :CopilotChatToggle<CR>
vnoremap <C-M-f> :CopilotChatFix<CR>
