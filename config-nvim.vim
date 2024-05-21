"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PROVIDERS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the following to setup python3 provider
" sudo pip3.6 install --upgrade neovim


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" theme
set background=dark

Plug 'folke/tokyonight.nvim'
autocmd VimEnter * colorscheme tokyonight


" nvim-treesitter/nvim-treesitter: A Neovim plugin for tree-sitter, a parser generator tool and an incremental parsing library. It helps to improve syntax highlighting and indentation.
function! TreesitterHook()
	:TSUpdate
	!npm i -g tree-sitter-cli tree-sitter
endfunction
Plug 'nvim-treesitter/nvim-treesitter', { 'do': { -> TreesitterHook() } }


" plenary.nvim: A Lua library for Neovim. It provides utility functions and classes which can be used by other plugins.
Plug 'nvim-lua/plenary.nvim'


" nvim-telescope/telescope.nvim: A highly extendable fuzzy finder over lists. It helps you to find and manage files, buffers, and much more.
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ECOSYSTEMS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if $NVIM_CONFIG == 'cmp'
	echom 'using config: nvim-cmp'
  " Source the nvim-cmp configuration file
  source $HOME/.vim/viml/nvim-cmp.vim
	source ${HOME}/.vim/viml/copilot-vim.vim
else
	echom 'using config: nvim-coc'
  " Source the coc-nvim configuration file
  source $HOME/.vim/viml/coc-nvim.vim
	source ${HOME}/.vim/viml/copilot-vim.vim
endif

"}}}
