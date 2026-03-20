vim.g.mapleader = "º"

local map = vim.keymap.set

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>")
map("n", "<leader>q", "<cmd>q<cr>")

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Neo-tree
map("n", "<C-o>", "<cmd>Neotree toggle<cr>")

-- Telescope
map("n", "<C-p>", "<cmd>Telescope find_files<cr>")
map("n", "<C-f>", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
