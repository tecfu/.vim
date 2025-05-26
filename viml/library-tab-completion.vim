" $HOME/.vim/viml/library-tab-completion.vim

function! TabCompletion_CopilotLuaIsVisible() abort
  echom "TabCompletion_CopilotLuaIsVisible: Checking..."
  let l:is_visible = 0 " Default to false

  let l:module_exists = 0
  try
    let l:module_exists = luaeval('select(1, pcall(require, "copilot.suggestion"))')
    echom "TabCompletion_CopilotLuaIsVisible: luaeval for pcall(require, 'copilot.suggestion') returned: " . string(l:module_exists)
  catch
    echom "TabCompletion_CopilotLuaIsVisible: EXCEPTION during luaeval for require check: " . v:exception
    let l:module_exists = 0
  endtry

  if l:module_exists == 1
    echom "TabCompletion_CopilotLuaIsVisible: 'copilot.suggestion' module seems to exist. Now checking is_visible()."
    try
      let l:is_visible = luaeval('require("copilot.suggestion").is_visible()')
      echom "TabCompletion_CopilotLuaIsVisible: luaeval for is_visible() returned: " . string(l:is_visible)
    catch
      echom "TabCompletion_CopilotLuaIsVisible: EXCEPTION during luaeval for is_visible: " . v:exception
      let l:is_visible = 0
    endtry
  else
    echom "TabCompletion_CopilotLuaIsVisible: 'copilot.suggestion' module does NOT seem to exist or pcall failed. Skipping is_visible() check."
    let l:is_visible = 0
  endif

  echom "TabCompletion_CopilotLuaIsVisible: Final l:is_visible value: " . string(l:is_visible)
  return (l:is_visible == 1) ? 1 : 0
endfunction

function! TabCompletion_AcceptCopilotLua() abort
  echom "TabCompletion_AcceptCopilotLua: Attempting to accept..."
  let l:result_str = "\<Tab>"

  let l:can_attempt_accept = 0
  try
    let l:can_attempt_accept = luaeval('(function() local s_ok, s = pcall(require, "copilot.suggestion"); if s_ok and s and type(s.accept) == "function" then return true else return false end end)()')
    echom "TabCompletion_AcceptCopilotLua: luaeval for pre-check returned: " . string(l:can_attempt_accept)
  catch
    echom "TabCompletion_AcceptCopilotLua: EXCEPTION during luaeval for accept pre-check: " . v:exception
    let l:can_attempt_accept = 0
  endtry

  if l:can_attempt_accept == 1
    echom "TabCompletion_AcceptCopilotLua: 'copilot.suggestion.accept' seems available. Attempting accept."
    try
      let l:accept_outcome = luaeval('(function() local s=require("copilot.suggestion"); if s.accept() then return "" else return "DECLINED_BY_LUA" end end)()')
      echom "TabCompletion_AcceptCopilotLua: luaeval for accept() returned: " . string(l:accept_outcome)

      if type(l:accept_outcome) == v:t_string && l:accept_outcome ==# ""
        let l:result_str = ""
        echom "TabCompletion_AcceptCopilotLua: Copilot.lua SUCCESS. Returning \"\"."
      else
        echom "TabCompletion_AcceptCopilotLua: Copilot.lua did not return \"\" (got " . string(l:accept_outcome) . "). Returning <Tab>."
      endif
    catch
      echom "TabCompletion_AcceptCopilotLua: EXCEPTION during luaeval for accept: " . v:exception
    endtry
  else
    echom "TabCompletion_AcceptCopilotLua: 'copilot.suggestion.accept' not available or pre-check failed. Returning <Tab>."
  endif
  return l:result_str
endfunction

function! TabCompletion_CopilotVimIsVisible() abort
  echom "TabCompletion_CopilotVimIsVisible: Checking..."
  if !exists('*copilot#GetDisplayedSuggestion')
    echom "TabCompletion_CopilotVimIsVisible: copilot#GetDisplayedSuggestion function does NOT exist."
    echom "TabCompletion_CopilotVimIsVisible: Defaulting to return 0."
    return 0
  endif

  echom "TabCompletion_CopilotVimIsVisible: copilot#GetDisplayedSuggestion function exists. Attempting to call."
  try
    let l:suggestion_dict = copilot#GetDisplayedSuggestion()
    echom "TabCompletion_CopilotVimIsVisible: copilot#GetDisplayedSuggestion() returned type: " . type(l:suggestion_dict)

    if type(l:suggestion_dict) == v:t_dict && has_key(l:suggestion_dict, 'text')
      echom "TabCompletion_CopilotVimIsVisible: Suggestion dict has 'text' key. Value: '" . l:suggestion_dict.text . "'"
      if !empty(l:suggestion_dict.text)
        echom "TabCompletion_CopilotVimIsVisible: Suggestion text is NOT empty. Returning 1."
        return 1
      else
        echom "TabCompletion_CopilotVimIsVisible: Suggestion text IS empty. Returning 0."
        return 0
      endif
    else
      echom "TabCompletion_CopilotVimIsVisible: copilot#GetDisplayedSuggestion() did not return a dict with 'text' key. Returning 0."
      return 0
    endif
  catch
    echom "TabCompletion_CopilotVimIsVisible: Error calling copilot#GetDisplayedSuggestion(): " . v:exception
    echom "TabCompletion_CopilotVimIsVisible: Defaulting to return 0."
    return 0
  endtry
endfunction

function! TabCompletion_AcceptCopilotVim() abort
  echom "TabCompletion_AcceptCopilotVim: Attempting to accept..."
  if exists('*copilot#Accept')
    echom "TabCompletion_AcceptCopilotVim: copilot#Accept exists."
    try
      " Directly return the result of copilot#Accept()
      " This result is what the <expr> mapping needs to execute.
      let l:accept_cmd = copilot#Accept()
      echom "TabCompletion_AcceptCopilotVim: copilot#Accept() returned: " . string(l:accept_cmd)
      " If copilot#Accept() returns an empty string, it might mean it handled it
      " without needing further keystrokes, or it failed to produce a command.
      " For safety, if it returns an empty string when we expect a command string,
      " we might fall back. However, typically it returns a non-empty command string
      " or handles completion internally and returns something to stop further mapping.
      " Let's assume if it returns a non-empty string, that's the command.
      " If it returns an empty string, perhaps it means "handled, do nothing more",
      " which is good for consuming the Tab.
      " If it means "error/no suggestion", then the IsVisible check should have caught it.
      if type(l:accept_cmd) == v:t_string
        return l:accept_cmd
      else
        echom "TabCompletion_AcceptCopilotVim: copilot#Accept() did not return a string. Fallback."
        return "\<Tab>" " Fallback if it didn't return a string
      endif
    catch
      echom "TabCompletion_AcceptCopilotVim: Error calling copilot#Accept(): " . v:exception
      echom "TabCompletion_AcceptCopilotVim: Returning <Tab> (exception)."
      return "\<Tab>"
    endtry
  else
    echom "TabCompletion_AcceptCopilotVim: copilot#Accept does NOT exist. Returning <Tab>."
    return "\<Tab>"
  endif
endfunction

function! TabCompletion_CheckBackspace() abort
  let col = col('.') - 1
  let result = !col || getline('.')[col - 1]  =~# '\s'
  return result
endfunction
