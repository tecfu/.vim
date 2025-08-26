"Load nvim config from vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
lua package.path = package.path .. ';' .. vim.fn.expand('$VIMRUNTIME') .. '/lua/?.lua;' .. vim.fn.expand('$VIMRUNTIME') .. '/lua/?/init.lua'
source ~/.vimrc

"luafile init.lua
