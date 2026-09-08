return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Git wrapper + GitHub integration (:GBrowse)
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    config = function()
      vim.api.nvim_create_user_command("Browse", function(opts)
        vim.ui.open(opts.fargs[1])
      end, { nargs = 1 })
    end,
  },

  -- Colorscheme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({ theme = "wave" })
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
      })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    -- Rama `main`: es una reescritura incompatible, no un bump. Ya no existen
    -- nvim-treesitter.configs ni nvim-treesitter.install, y desaparecen
    -- ensure_installed, auto_install, highlight e indent. El plugin ahora solo
    -- instala parsers y queries; el resaltado lo da Neovim y hay que
    -- encenderlo a mano (el autocmd de abajo).
    --
    -- `master` sigue existiendo pero esta archivada upstream, sin arreglos ni
    -- parsers nuevos, asi que no es sitio donde quedarse.
    --
    -- Requiere nvim >= 0.12, tree-sitter-cli >= 0.26.1 (por brew, NO por npm),
    -- curl, tar y un compilador de C.
    branch = "main",
    -- Upstream dice explicitamente que no soporta lazy-loading.
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()

      -- Sustituye a ensure_installed. Es no-op si ya estan instalados, y
      -- asincrono: no bloquea el arranque.
      ts.install({
        "python",
        "lua",
        "vim",
        "vimdoc",
        "elixir",
        "eex",
        "heex",
        "javascript",
        "typescript",
        "tsx",
        "json",
        -- Los dos hacen falta para render-markdown.nvim (plugins/markdown.lua):
        -- markdown da la estructura de bloque (cabeceras, listas, tablas) y
        -- markdown_inline lo de dentro de la linea (enfasis, links, code spans).
        "markdown",
        "markdown_inline",
      })

      -- Sustituye a highlight = { enable = true } e indent = { enable = true }.
      -- Sin pattern: vim.treesitter.start() resuelve el filetype -> lenguaje el
      -- solo, lo que evita tener que mapear a mano los casos en que no
      -- coinciden (tsx -> typescriptreact, vimdoc -> help, eex -> eelixir).
      -- El pcall es el guarda: start() falla si no hay parser para ese
      -- filetype, y eso pasa constantemente en ficheros cualquiera.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if pcall(vim.treesitter.start) then
            -- Upstream marca el indentado como experimental.
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = { width = 30 },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
      })
    end,
  },
}
