"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" theme
set background=dark

Plug 'folke/tokyonight.nvim'
autocmd VimEnter * colorscheme tokyonight

source $HOME/.vim/viml/nvim-plenary.nvim
source $HOME/.vim/viml/telescope.nvim
source $HOME/.vim/viml/swagger-preview.nvim

if $NVIM_CONFIG == 'cmp'
  echom 'NVIM_CONFIG=cmp'
  "source $HOME/.vim/viml/copilot.vim
  source $HOME/.vim/viml/copilot.lua.nvim
  source $HOME/.vim/viml/copilot-chat.nvim
  source $HOME/.vim/viml/nvim-lsp-setup.nvim
  source $HOME/.vim/viml/nvim-lsp-formatting.nvim
  " source $HOME/.vim/viml/nvim-cmp.nvim
  " source $HOME/.vim/viml/nvim-treesitter.nvim
  " source $HOME/.vim/viml/debugging.nvim
else
  echom 'NVIM_CONFIG=coc'
  source $HOME/.vim/viml/coc-nvim.vim
  source $HOME/.vim/viml/copilot.vim
  source $HOME/.vim/viml/copilot-chat.nvim
  source $HOME/.vim/viml/nvim-treesitter.nvim
endif
"}}}
