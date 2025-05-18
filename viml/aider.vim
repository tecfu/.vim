Plug 'joshuavial/aider.nvim'

" inherit from ~/.aider.conf.yaml instead
"let g:aider_model = 'gemini/gemini-exp-1206'

function! SetupAider()
  lua << EOF
require('aider').setup({
  auto_manage_context = false,
  default_bindings = false,
  debug = true,
  vim = true, 
  ignore_buffers = {},
})
EOF
endfunction

" Function to toggle Aider
function! ToggleAider()
  let aider_bufnr = -1
  " Filetype for Aider buffers
  let aider_filetype = 'AiderConsole'

  " Check if an Aider buffer exists
  for buf in range(1, bufnr('$'))
    if bufexists(buf) && getbufvar(buf, '&filetype') ==# aider_filetype
      let aider_bufnr = buf
      break
    endif
  endfor

  if aider_bufnr != -1
    " Aider buffer exists, check if it is visible
    let aider_winid = -1
    for win in range(1, winnr('$'))
      if winbufnr(win) == aider_bufnr
        let aider_winid = win
        break
      endif
    endfor

    if aider_winid != -1
      " Aider buffer is visible, close its window
      execute aider_winid . 'wincmd c'
    else
      " Aider buffer is hidden, focus it in the existing vertical split or create one
      execute 'vert sbuffer ' . aider_bufnr
    endif
  else
    " No Aider buffer exists, open a new session
    "let cmd = 'AiderOpen --model ' . g:aider_model . ' --no-auto-commits'
    let cmd = 'AiderOpen --no-auto-commits'
    echom 'Executing: ' . cmd
    execute cmd
  endif
endfunction

" Add a keybinding to toggle the chat window
nnoremap <C-M-a> :call ToggleAider()<CR>
" <Ctrl-Command-letter> for Mac
nnoremap <D-C-a> :call ToggleAider()<CR>

" Command to set the model
command! -nargs=1 AiderSetModel let g:aider_model = <q-args> | call SetupAider()
" Usage:
" :AiderSetModel gemini/gemini-exp-1206

autocmd VimEnter * call SetupAider()

