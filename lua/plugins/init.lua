-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

return {
  -- General
  'morhetz/gruvbox',
  'kyazdani42/nvim-tree.lua',
  'kyazdani42/nvim-web-devicons',
  'airblade/vim-gitgutter',
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  'SirVer/ultisnips',
  'honza/vim-snippets',
  'voldikss/vim-floaterm',
  'vim-test/vim-test',
  'tpope/vim-dotenv',
  'github/copilot.vim',

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- install different completion source
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        -- add different completion source
        sources = cmp.config.sources({
          { name = 'cmdline' },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        -- using default mapping preset
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        snippet = {
          -- you must specify a snippet engine
          expand = function(args)
            -- using neovim v0.10 native snippet feature
            -- you can also use other snippet engines
            vim.snippet.expand(args.body)
          end,
        },
      })
    end,
  },
  'neovim/nvim-lspconfig',
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.elixirls.setup({
        cmd = { "/Users/alvarovillen/.elixir-ls/release/language_server.sh" },
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
        elixirLS = {
          dialyzerEnabled = true,
          fetchDeps = true,
        };
      })

      lspconfig.tailwindcss.setup({
        init_options = {
          userLanguages = {
            elixir = "html-eex",
            eelixir = "html-eex",
            heex = "html-eex",
          },
        },
      })

    end,
  },

  -- Telescope
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "elixir",
          "heex",
          "eex",
          "html",
          "go",
          "gleam",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline"
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  {'nvim-telescope/telescope.nvim', dependencies = {{'nvim-lua/plenary.nvim'}}},
  {'kelly-lin/telescope-ag', dependencies = {{ "nvim-telescope/telescope.nvim" }}},
  'fannheyward/telescope-coc.nvim',

  'tpope/vim-fugitive',
  'shumphrey/fugitive-gitlab.vim',
  'tpope/vim-rhubarb',

  -- Elixir
  'elixir-editors/vim-elixir',

  -- Ruby
  'vim-ruby/vim-ruby',
  'tpope/vim-rails',

  -- Systems
  'hashivim/vim-terraform',
}
