require('nvim-tree').setup({
  disable_netrw = false,
  hijack_netrw = true,
  renderer = {
    icons = {
      show = {
        folder_arrow = false,
        folder = true,
        file = true,
        git = true
      }
    }
  }
})

-- Toggle NvimTree
vim.api.nvim_set_keymap("n", "<C-O>", ':NvimTreeFindFileToggle<CR>', {})
