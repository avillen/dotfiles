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
      local python_tests = require("config.python_tests")

      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            args = { "-vv" },
            pytest_discover_instances = true,
            is_test_file = python_tests.is_python_test_file,
          }),
        },
      })
    end,
  },
}
