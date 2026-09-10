" Fallback filetype detection (setfiletype never overrides an existing ft)
autocmd BufNewFile,BufReadPost *.md setfiletype markdown
autocmd BufNewFile,BufRead coc-settings.json,*.jsonc setfiletype jsonc
autocmd BufNewFile,BufRead *.cjs setfiletype javascript
autocmd BufEnter *.nvim setlocal filetype=vim
