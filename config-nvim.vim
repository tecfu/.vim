"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" theme
set background=dark

call plug#begin('~/.vim/plugins-nvim')
  source $HOME/.vim/config-common.vim

  Plug 'folke/tokyonight.nvim'
  autocmd VimEnter * colorscheme tokyonight

  source $HOME/.vim/viml/toggle-terminal.nvim
  source $HOME/.vim/viml/nvim-plenary.nvim
  source $HOME/.vim/viml/swagger-preview.nvim
  source $HOME/.vim/viml/project.nvim
  source $HOME/.vim/viml/telescope.nvim
  source $HOME/.vim/viml/aider.vim

  if $NVIM_CONFIG == 'cmp'
    " Using both copilot.vim and copilot.lua.nvim is a hack.
    " copilot.vim suggestions wont show up in nvim-cmp, but supports accepting next word with <CR>
    " copilot.lua.nvim suggestions will show up in nvim-cmp, but does not support accepting next word with <CR>
    " Together they provide desired functionality
    source $HOME/.vim/viml/copilot.lua.nvim
    source $HOME/.vim/viml/copilot-chat.nvim
    "source $HOME/.vim/viml/codecompanion.nvim
    source $HOME/.vim/viml/nvim-efm-langserver-setup.nvim
    source $HOME/.vim/viml/nvim-lsp-diagnostic-window.nvim
    source $HOME/.vim/viml/nvim-cmp.nvim
    " source $HOME/.vim/viml/debugging.nvim
    " source $HOME/.vim/viml/nvim-dap.nvim
  else
    source $HOME/.vim/viml/coc-nvim.vim
    source $HOME/.vim/viml/copilot.vim
    source $HOME/.vim/viml/copilot-chat.nvim
  endif
call plug#end()
"}}}
