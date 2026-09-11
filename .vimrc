" Set this before sourcing anything: compatible mode changes Vimscript parsing.
set nocompatible

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Entry point. Everything else lives in runtimepath-native locations:
"   plugin/            auto-sourced by vim AND nvim (shared settings)
"   after/ftplugin/    per-filetype settings, auto-sourced per buffer
"   ftdetect/          filetype detection fallbacks
"   viml/              opt-in / editor-specific extras
"   config-common.vim  shared plugin list (sourced inside plug#begin)
"   config-nvim.vim    nvim plugin entry
"   config-vim.vim     vim plugin entry
"
" Opt-in startup profiling:  VIM_PROFILE=1 nvim   (or vim)
"
" Use our own fence-aware markdown folding (after/ftplugin/markdown.vim),
" not vim-markdown's -- its BufWinEnter autocmds would otherwise re-apply
" Foldexpr_markdown over ours on every buffer enter.
let g:vim_markdown_folding_disabled = 1
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Startup Profiling (opt-in via $VIM_PROFILE)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !empty($VIM_PROFILE)
  source $HOME/.vim/viml/startup-profile.vim
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Set utf8 as standard encoding and en_US as the standard language
" Neovim requires it be done here
set encoding=utf8
set fileencoding=utf8

" For running nvim on git bash in windows
if has('win32') || has('win64')
  " This is a message to confirm the block is running. You can remove it later.
  echom "Configuring shell for Windows..."

  " Native Neovim inherits Git Bash's SHELL, but keeps cmd.exe flags. Besides
  " breaking commands, that starts an MSYS process for every system() call.
  let &shell = empty($COMSPEC) ? 'cmd.exe' : $COMSPEC
  let &shellcmdflag = '/s /c'
  let &shellquote = ''
  let &shellxquote = '"'
  let &shellredir = '>%s 2>&1'

  " Locate Git Bash for :Bash, without slowing every system() call by
  " replacing the native shell. Git may be installed per-machine
  " (e.g. "C:/Program Files/Git") or per-user (e.g. under
  " "AppData/Local/Programs/Git"), so derive it from wherever `git` itself
  " resolves on PATH, falling back to common install locations.
  function! s:FindGitBash() abort
    let l:git_path = exepath('git')
    if !empty(l:git_path)
      " git.exe lives at "<GitRoot>/cmd/git.exe" or "<GitRoot>/bin/git.exe"
      let l:git_root = fnamemodify(l:git_path, ':h:h')
      for l:candidate in [l:git_root . '/usr/bin/bash.exe', l:git_root . '/bin/bash.exe']
        if filereadable(l:candidate)
          return l:candidate
        endif
      endfor
    endif

    for l:candidate in [
          \ 'C:/Program Files/Git/usr/bin/bash.exe',
          \ 'C:/Program Files (x86)/Git/usr/bin/bash.exe',
          \ expand('~/AppData/Local/Programs/Git/usr/bin/bash.exe'),
          \ ]
      if filereadable(l:candidate)
        return l:candidate
      endif
    endfor

    return ''
  endfunction

  let s:git_bash = s:FindGitBash()
  if !empty(s:git_bash)
    let g:git_bash = s:git_bash
    command! -nargs=* Bash call vimrc#bash(<q-args>)
  else
    echom "WARNING: Could not find Git Bash (bash.exe). The :Bash command will be unavailable."
  endif
endif

" Check if $NVIM_CONFIG is empty (unset variables often evaluate to empty)
if empty($NVIM_CONFIG)
  " If it is empty, set an internal global Vimscript variable g:nvim_config
  let g:nvim_config = "cmp-builtin"
else
  " Otherwise, set the internal variable to the value of the environment variable
  let g:nvim_config = $NVIM_CONFIG
endif

" Initialize CoC variables (used in echo message even if not in CoC mode)
if empty($COC_PROFILE)
  let g:coc_profile = "default"
else
  let g:coc_profile = $COC_PROFILE
endif

let g:coc_profile_dir = expand('$HOME/.vim/coc-profiles/') . g:coc_profile
let g:coc_config_home = g:coc_profile_dir

function! s:ShowStartupMessage()
  let msg = "NVIM_CONFIG=" . g:nvim_config
  if g:nvim_config == 'coc'
    let msg = msg . " | COC_PROFILE=" . get(g:, 'coc_profile', 'unset') . " | COC_CONFIG_HOME=" . get(g:, 'coc_config_home', 'unset')
  endif
  call s:ScheduleEchoMessage(msg, 500)
endfunction

augroup DelayedEchoMsg
  autocmd!
  autocmd VimEnter * call s:ShowStartupMessage()
augroup END

function! s:ScheduleEchoMessage(message, delay_ms)
  let l:timer_id = timer_start(a:delay_ms, function('s:EchoMessageCallback', [a:message]))
endfunction

function! s:EchoMessageCallback(message, timer_id)
  echom a:message
endfunction

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if has("nvim")
  source $HOME/.vim/config-nvim.vim
else
  source $HOME/.vim/config-vim.vim
endif

" vim-plug unexpectedly configures indentation. undo this
" https://vi.stackexchange.com/questions/10124/what-is-the-difference-between-filetype-plugin-indent-on-and-filetype-indent
"}}}
