-- Only external plugin APIs are doubled. Never replace vim.lsp/vim.diagnostic:
-- the mode configs must register, enable, attach and exchange real LSP messages.
local state = { visible = false, confirmed = false }
local mapping = setmetatable({
  scroll_docs = function() return function() end end,
  complete = function() return function() end end,
  abort = function() return function() end end,
  preset = { cmdline = function() return {} end },
}, { __call = function(_, callback) return callback end })
local setup = setmetatable({
  cmdline = function() end,
  filetype = function() end,
}, { __call = function(_, config) state.cmp = config end })
package.preload.cmp = function()
  return {
    mapping = mapping, setup = setup,
    config = { sources = function(sources) return sources end },
    SelectBehavior = { Select = 1 },
    visible = function() return state.visible end,
    confirm = function() state.confirmed = true end,
  }
end
package.preload.cmp_nvim_lsp = function()
  return { default_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end }
end

ModeTests = {}
function ModeTests.run()
  local mode = vim.g.nvim_config
  local registry = vim.json.decode(table.concat(vim.fn.readfile(
    vim.fn.expand('~/.vim/lsp-servers.json')), '\n')).servers
  assert(not state.cmp, 'nvim-cmp must remain unloaded through VimEnter')
  vim.cmd.doautocmd('InsertEnter')
  assert(state.cmp, 'The real SetupCmp must run on first completion use')
  assert(vim.fn.index(vim.g.test_plug_loads, 'nvim-cmp') >= 0,
    'SetupCmp must request the lazy nvim-cmp plugin: ' .. vim.inspect(vim.g.test_plug_loads))
  assert(state.cmp.sources[1].name == 'nvim_lsp')
  local fallback = false
  state.cmp.mapping['<CR>'](function() fallback = true end)
  assert(fallback, 'Enter must fall back when the completion menu is hidden')
  state.visible = true
  state.cmp.mapping['<CR>'](function() error('Unexpected completion fallback') end)
  assert(state.confirmed, 'Enter must confirm the visible completion')

  if mode == 'cmp-efm' then
    assert(vim.lsp.is_enabled('efm'))
    assert(vim.fn.exists('*SetupLspBuiltin') == 0, 'cmp-efm must remain EFM-only')
    for _, server in ipairs(registry) do
      assert(not vim.lsp.is_enabled(server.name), 'Unexpected native server: ' .. server.name)
    end
    local config = vim.lsp.config.efm
    assert(config.init_options.documentFormatting)
    assert(config.handlers['textDocument/publishDiagnostics'])
    assert(config.cmd[2] == '-c')
    assert(config.cmd[3] == vim.fn.expand('~/.vim/efm-langserver-config.yaml'))
    assert(config.cmd[5] == vim.fn.stdpath('state') .. '/efm-langserver.log')
    -- Substitute only the process; keep real EFM capabilities/handlers/attach.
    vim.lsp.config('efm', { cmd = {
      vim.env.VIM_TEST_PYTHON,
      vim.env.VIM_TEST_ROOT .. '/scripts/test-modes-lsp.py', 'efm',
    } })
  else
    assert(not vim.lsp.is_enabled('efm'))
    for _, server in ipairs(registry) do
      assert(not vim.lsp.is_enabled(server.name),
        'Native LSP must remain disabled until a supported FileType')
    end
  end

  for index, language in ipairs({ 'python', 'go' }) do
    local extension = language == 'python' and 'py' or 'go'
    vim.cmd.edit(vim.fn.fnameescape(vim.env.VIM_TEST_PROJECT .. '/example.' .. extension))
    local buf = vim.api.nvim_get_current_buf()
    assert(vim.bo[buf].filetype == language)
    if mode ~= 'cmp-efm' and index == 1 then
      assert(vim.wait(10000, function()
        return vim.g.lsp_builtin_setup_done == 1
      end, 20), 'Native LSP setup timer never ran')
      assert(vim.g.lsp_builtin_setup_done == 1,
        'Native LSP must initialize on the first supported FileType')
      for _, server in ipairs(registry) do
        assert(vim.lsp.is_enabled(server.name), 'Server not enabled: ' .. server.name)
        local config = vim.lsp.config[server.name]
        assert(vim.deep_equal(config.filetypes, server.filetypes))
        assert(vim.deep_equal(config.settings or {}, server.settings or {}))
        assert(config.capabilities.textDocument.completion.completionItem.snippetSupport)
      end
    end
    local expected = {}
    if mode == 'cmp-efm' then
      expected.efm = true
    else
      for _, server in ipairs(registry) do
        if vim.tbl_contains(server.filetypes, language) then expected[server.name] = true end
      end
    end
    assert(vim.wait(10000, function()
      local found = {}
      for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do found[diagnostic.source] = true end
      return vim.deep_equal(found, expected)
    end, 20), 'LSP diagnostics never arrived for ' .. language)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    assert(#clients == vim.tbl_count(expected))
    for _, client in ipairs(clients) do
      assert(expected[client.name], 'Wrong LSP attached: ' .. client.name)
      assert(client.server_capabilities.documentFormattingProvider)
      local response = client:request_sync('textDocument/completion', {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        position = { line = 0, character = 0 },
      }, 3000, buf)
      assert(response and not response.err)
      assert(response.result[1].label == 'fixture_completion')
    end
    assert(vim.fn.maparg('\\l', 'n', false, true).buffer == 1, 'Missing LspAttach format map')
    if mode ~= 'cmp-efm' then
      assert(vim.bo[buf].omnifunc == 'v:lua.vim.lsp.omnifunc')
      assert(vim.bo[buf].formatexpr == 'v:lua.vim.lsp.formatexpr()')
    end
    vim.fn.SetLocationList()
    local locations = vim.fn.getloclist(0)
    assert(#locations == #clients and locations[1].type == 'W')
    assert(locations[1].text:find('fixture diagnostic for ' .. language, 1, true))
    vim.lsp.buf.format({ bufnr = buf, id = clients[1].id, timeout_ms = 3000 })
    assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:find('fixture formatted', 1, true))
  end
end
