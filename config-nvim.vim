"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" theme
set background=dark

Plug 'folke/tokyonight.nvim'
autocmd VimEnter * colorscheme tokyonight

source $HOME/.vim/viml/nvim-plenary.nvim
source $HOME/.vim/viml/telescope.nvim

if $NVIM_CONFIG == 'cmp'
  echom 'using config: nvim-cmp'
  source $HOME/.vim/viml/copilot-vim.nvim
  source $HOME/.vim/viml/nvim-lsp-setup.nvim
  source $HOME/.vim/viml/nvim-lsp-formatting.nvim
  source $HOME/.vim/viml/nvim-cmp.nvim
  source $HOME/.vim/viml/nvim-treesitter.nvim
else
  echom 'using config: nvim-coc'
  source $HOME/.vim/viml/coc-nvim.vim
  source $HOME/.vim/viml/copilot-vim.nvim
  source $HOME/.vim/viml/nvim-treesitter.nvim
endif
"}}}
