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
  " disabled until can configure not to use premium requests from github
  "source $HOME/.vim/viml/copilot-chat.nvim 
  source $HOME/.vim/viml/gitsigns.nvim

  if $NVIM_CONFIG == 'coc'
    source $HOME/.vim/viml/coc-nvim.vim
    source $HOME/.vim/viml/copilot.vim
  elseif $NVIM_CONFIG == 'cmp-efm'
    source $HOME/.vim/viml/nvim-lsp-efm.nvim
    source $HOME/.vim/viml/nvim-lsp-diagnostic-window.nvim
    source $HOME/.vim/viml/nvim-cmp.nvim
  else
    " Default to cmp-builtin
    source $HOME/.vim/viml/nvim-lsp-builtin.nvim
    source $HOME/.vim/viml/nvim-lsp-diagnostic-window.nvim
    source $HOME/.vim/viml/nvim-cmp.nvim
  endif
call plug#end()
"}}}
