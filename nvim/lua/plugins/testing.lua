return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            python = function()
              local venv = vim.fn.getcwd() .. "/.venv/bin/python"
              if vim.fn.filereadable(venv) == 1 then
                return venv
              end
              return "python3"
            end,
          }),
        },
      })
    end,
  },
}
