" nvim-cmp: A completion engine plugin for Neovim. It provides an extensible and customizable framework for text completion.
Plug 'hrsh7th/nvim-cmp'

" cmp-buffer: A buffer source for nvim-cmp. It provides completion items from the current and other open buffers.
Plug 'hrsh7th/cmp-buffer'

" cmp-nvim-lsp: A Language Server Protocol (LSP) source for nvim-cmp. It provides completion items based on LSP.
Plug 'hrsh7th/cmp-nvim-lsp'

" cmp-path: A file path source for nvim-cmp. It provides completion for file paths.
Plug 'hrsh7th/cmp-path'

" cmp-cmdline: A command line source for nvim-cmp. It provides completion for command line mode.
Plug 'hrsh7th/cmp-cmdline'"

" mason.nvim: A plugin manager for Neovim. It helps to manage and load plugins.
Plug 'williamboman/mason.nvim'

" mason-lspconfig.nvim: Provides configurations for setting up Language Server Protocol (LSP) with mason.nvim.
Plug 'williamboman/mason-lspconfig.nvim'

" nvim-lspconfig: A collection of common configurations for Neovim's built-in LSP client. It makes setting up Neovim's LSP client easier.
Plug 'neovim/nvim-lspconfig'

" LuaSnip: A snippet engine for Neovim. It allows for faster coding via reusable code snippets.
Plug 'L3MON4D3/LuaSnip'


function! VimrcSetupPlugins()
lua << EOF

  require("mason").setup({
      ui = {
          icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗"
          }
      }
  })

  -- List of available servers: https://github.com/williamboman/mason-lspconfig.nvim
  local lspservers = {
    'eslint',
    'vacuum', -- OPEN API Validator
    'tsserver',
    'vimls',
  }

  require('mason-lspconfig').setup({
    ensure_installed = lspservers
  })

  -- local tabnine = require('cmp_tabnine.config')
  -- tabnine:setup({
  --   max_lines = 1000,
  --   max_num_results = 20,
  --   sort = true,
  --   run_on_every_keystroke = true,
  --   snippet_placeholder = '..',
  --   ignored_file_types = {
  --     -- default is not to ignore
  --     -- uncomment to ignore in lua:
  --     -- lua = true
  --   },
  --   show_prediction_strength = false,
  --   lazy = true,
  --   event = "InsertEnter"
  -- })

  --
  -- Set up treesitter
  --
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "javascript",
      "typescript",
      "c",
      "lua",
      "vim"
    },
    auto_install = true,
    highlight = {
      enable = true,                -- Enable syntax highlighting
    },
  }
  -- nvim-treesitter.install.update()

  --
  -- Set up cmp_nvim_lsp
  --
  local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
  local lsp_on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = true

    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    -- following keymap is based on both lspconfig and lsp-zero.nvim:
    -- - https://github.com/neovim/nvim-lspconfig/blob/fd8f18fe819f1049d00de74817523f4823ba259a/README.md?plain=1#L79-L93
    -- - https://github.com/VonHeikemen/lsp-zero.nvim/blob/18a5887631187f3f7c408ce545fd12b8aeceba06/lua/lsp-zero/server.lua#L285-L298
    vim.keymap.set('n', 'gh'   , vim.lsp.buf.signature_help                        , bufopts)
    vim.keymap.set('n', 'gv'   , vim.lsp.buf.hover                                 , bufopts)
    vim.keymap.set('n', 'gD'   , vim.lsp.buf.declaration                           , bufopts)
    vim.keymap.set('n', 'gd'   , vim.lsp.buf.definition                            , bufopts)
    vim.keymap.set('n', 'gi'   , vim.lsp.buf.implementation                        , bufopts)
    vim.keymap.set('n', 'go'   , vim.lsp.buf.type_definition                       , bufopts)
    vim.keymap.set('n', 'gr'   , vim.lsp.buf.references                            , bufopts)
    --m.keymap.set('n', TODO   , vim.lsp.buf.code_action                           , bufopts) -- lspconfig: <space>ca; lsp-zero: <F4>
    vim.keymap.set('n', '<space>l', function() vim.lsp.buf.format { async = true } end, bufopts) -- lspconfig: <space>l
    --m.keymap.set('n', TODO   , vim.lsp.buf.rename                                , bufopts) -- lspconfig: <space>rn; lsp-zero: <F2>
  end

  local lspconfig = require('lspconfig')
  local has_words_before = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    return not vim.api.nvim_get_current_line():sub(1, cursor[2]):match('^%s$')
  end

  -- enable both language-servers for both eslint and typescript:
  -- for _, server in pairs(lspservers) do
  -- BUG: For some reason you must load tsserver twice
  for _, server in pairs({ 'tsserver', 'tsserver' }) do
    lspconfig[server].setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_on_attach,
    })
  end

  --
  -- Set up nvim-cmp.
  --
  local luasnip = require('luasnip')
  local CustomDown = function(fallback,cmp)
    if cmp.visible() then
      cmp.select_next_item()
    -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
    -- they way you will only jump inside the snippet region
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end

  local CustomUp = function(fallback,cmp)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end

  local cmp = require('cmp')
  local baseMappings = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping(function(fallback)
        CustomDown(fallback,cmp)
    end, { 'i', 's' }),
    ['<C-k>'] = cmp.mapping(function(fallback)
        CustomUp(fallback, cmp)
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
        elseif cmp.visible() then
            cmp.select_next_item()
        else
            fallback()
        end
    end, { 'i', 's' }),
  }


  cmp.setup({
  completion = { completeopt = 'menu,menuone,noinsert' },
  mapping = cmp.mapping.preset.insert(baseMappings),
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'copilot', group_index = 1 },
    { name = 'path', group_index = 2 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'luasnip', group_index = 2 },
    { name = 'buffer', group_index = 2 },
  })
})

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline({
        ['<C-j>'] = {
        c = function(_)
             cmp.select_next_item()
        end,
        },
        ['<C-k>'] = {
        c = function(_)
             cmp.select_prev_item()
        end,
        }
    }),
    sources = {
      { name = 'buffer' }
    }
  })
EOF
endfunction

"Call the function after Vim has finished starting up
autocmd VimEnter * call VimrcSetupPlugins()
