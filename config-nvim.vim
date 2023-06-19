"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LANGUAGE SERVER
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Will fail on first run because plugin  not installed.
Plug 'nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AUTOCOMPLETION
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'

" :MasonUpdate updates registry contents. Will fail on first run because plugin  not installed.
" Plug 'williamboman/mason.nvim', {'do': 'MasonUpdate'}
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'tzachar/cmp-tabnine', {'do': './install.sh'}
Plug 'zbirenbaum/copilot.lua'
Plug 'zbirenbaum/copilot-cmp'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GENERAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Plug 'windwp/nvim-ts-autotag'


function! VimrcSetupPlugins(timer)
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
    'rust_analyzer',
    'clangd',
    'pyright',
    'tsserver',
    'eslint',
  }
  require('mason-lspconfig').setup({
    ensure_installed = lspservers
  })

  require("copilot_cmp").setup()

  local tabnine = require('cmp_tabnine.config')
  tabnine:setup({
    max_lines = 1000,
    max_num_results = 20,
    sort = true,
    run_on_every_keystroke = true,
    snippet_placeholder = '..',
    ignored_file_types = {
      -- default is not to ignore
      -- uncomment to ignore in lua:
      -- lua = true
    },
    show_prediction_strength = false,
    lazy = true,
    event = "InsertEnter"
  })

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
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    -- following keymap is based on both lspconfig and lsp-zero.nvim:
    -- - https://github.com/neovim/nvim-lspconfig/blob/fd8f18fe819f1049d00de74817523f4823ba259a/README.md?plain=1#L79-L93
    -- - https://github.com/VonHeikemen/lsp-zero.nvim/blob/18a5887631187f3f7c408ce545fd12b8aeceba06/lua/lsp-zero/server.lua#L285-L298
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help                        , bufopts)
    vim.keymap.set('n', 'K'    , vim.lsp.buf.hover                                 , bufopts)
    vim.keymap.set('n', 'gD'   , vim.lsp.buf.declaration                           , bufopts)
    vim.keymap.set('n', 'gd'   , vim.lsp.buf.definition                            , bufopts)
    vim.keymap.set('n', 'gi'   , vim.lsp.buf.implementation                        , bufopts)
    vim.keymap.set('n', 'go'   , vim.lsp.buf.type_definition                       , bufopts)
    vim.keymap.set('n', 'gr'   , vim.lsp.buf.references                            , bufopts)
    --m.keymap.set('n', TODO   , vim.lsp.buf.code_action                           , bufopts) -- lspconfig: <space>ca; lsp-zero: <F4>
    --m.keymap.set('n', TODO   , function() vim.lsp.buf.format { async = true } end, bufopts) -- lspconfig: <space>f
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
    cmp.setup({
      completion = { completeopt = 'menu,menuone,noinsert' },
      -- if desired, choose another keymap-preset:
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<C-j>'] = cmp.mapping(function(fallback)
            CustomDown(fallback,cmp)  
        end, { 'i', 's' }),
        ['<C-k>'] = cmp.mapping(function(fallback)
            CustomUp(fallback, cmp)   
        end, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            CustomDown(fallback,cmp)  
        end, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if vim.fn.pumvisible() == 1 then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n', true)
              elseif has_words_before() and luasnip.expand_or_jumpable() then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
          else
            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function()
          if vim.fn.pumvisible() == 1 then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n', true)
          elseif luasnip.jumpable(-1) then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '', true)
          end
        end, { 'i', 's' }),
      }),
      -- optionally, add more completion-sources:
      -- sources = cmp.config.sources({
      --   { name = 'nvim_lsp' }
      -- }),
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          luasnip.lsp_expand(args.body) -- For `luasnip` users.
          -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'copilot' },
        { name = 'cmp_tabnine' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
        { name = 'buffer' },
      })
    })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
      { name = 'cmdline' }
    })
  })

EOF
endfunction
call timer_start(1000, 'VimrcSetupPlugins')
