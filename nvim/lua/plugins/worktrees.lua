return {
  {
    "afonsofrancof/worktrees.nvim",
    event = "VeryLazy",
    config = function()
      require("worktrees").setup({
        -- Relative to the git common dir (.git in a normal repo).
        base_path = "../../worktrees",
      })
    end,
  },
}
