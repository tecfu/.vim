"Load nvim config from vim
if (has('win32') || has('win64')) && $HOME =~# '^/\a/'
  " Native Windows Neovim cannot resolve an inherited MSYS /c/Users/... home.
  let $HOME = substitute($HOME, '^/\(\a\)/', '\1:/', '')
endif
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if has('nvim')
  lua package.path = package.path .. ';' .. vim.fn.expand('$VIMRUNTIME') .. '/lua/?.lua;' .. vim.fn.expand('$VIMRUNTIME') .. '/lua/?/init.lua'
endif
source ~/.vimrc

"luafile init.lua
