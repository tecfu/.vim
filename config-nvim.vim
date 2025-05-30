"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" theme
set background=dark

call plug#begin('~/.vim/plugins-nvim')
  source $HOME/.vim/config-common.vim

  Plug 'folke/tokyonight.nvim'
  autocmd VimEnter * colorscheme tokyonight

  " custom config files
  source $HOME/.vim/viml/toggle-terminal.nvim
  source $HOME/.vim/viml/nvim-plenary.nvim
  source $HOME/.vim/viml/swagger-preview.nvim
  "source $HOME/.vim/viml/project.nvim
  source $HOME/.vim/viml/telescope.nvim
  source $HOME/.vim/viml/aider.vim
  source $HOME/.vim/viml/copilot-chat.nvim

  if $NVIM_CONFIG == 'cmp'
    "source $HOME/.vim/viml/codecompanion.nvim
    "source $HOME/.vim/viml/nvim-efm-langserver-setup.nvim
    source $HOME/.vim/viml/nvim-lsp-setup.nvim
    source $HOME/.vim/viml/nvim-lsp-diagnostic-window.nvim
    source $HOME/.vim/viml/nvim-cmp.nvim
    " copilot.vim doesn't duplicate ghost text, coplot.lua.nvim does     
    " source $HOME/.vim/viml/copilot.lua.nvim
    " but copilot.vim causes lsp to crash
    "source $HOME/.vim/viml/copilot.vim
    " source $HOME/.vim/viml/debugging.nvim
    " source $HOME/.vim/viml/nvim-dap.nvim
  else
    source $HOME/.vim/viml/copilot.vim
    source $HOME/.vim/viml/coc-nvim.vim
  endif
call plug#end()
"}}}
