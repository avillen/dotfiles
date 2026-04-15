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
      local is_python_test_file = function(file_path)
        if not vim.endswith(file_path, ".py") then
          return false
        end

        local normalized_path = file_path:gsub("\\", "/")
        local file_name = vim.fn.fnamemodify(file_path, ":t")

        return file_name == "test.py"
          or file_name == "tests.py"
          or vim.startswith(file_name, "test_")
          or vim.endswith(file_name, "_test.py")
          or vim.endswith(file_name, "_tests.py")
          or normalized_path:match("/tests?/") ~= nil
      end

      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            pytest_discover_instances = true,
            is_test_file = is_python_test_file,
          }),
        },
      })
    end,
  },
}
