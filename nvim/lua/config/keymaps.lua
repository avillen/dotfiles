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
map("n", "<C-o>", "<cmd>Neotree reveal toggle<cr>")

-- Previous buffer
map("n", "<leader><leader>", "<C-^>")

-- Telescope
map("n", "<C-p>", "<cmd>Telescope find_files<cr>")
map("n", "<C-f>", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")

-- Resize splits
map("n", "<Left>", "<cmd>vertical resize -2<cr>")
map("n", "<Right>", "<cmd>vertical resize +2<cr>")
map("n", "<Up>", "<cmd>resize -2<cr>")
map("n", "<Down>", "<cmd>resize +2<cr>")

-- Tabs
map("n", "tn", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "tN", "<C-w>T", { desc = "Move window to new tab" })

-- Neotest
map("n", "tt", function() require("neotest").run.run() end, { desc = "Run nearest test" })
map("n", "to", function() require("neotest").summary.toggle() end, { desc = "Toggle summary" })

-- Diffview
map("n", "gd", "<cmd>DiffviewOpen<cr>")
map("n", "gh", "<cmd>DiffviewFileHistory %<cr>")
map("n", "gc", "<cmd>DiffviewClose<cr>")

-- Copy file path to clipboard
map("n", "yp", '<cmd>let @+ = expand("%")<cr>')
map("n", "yP", '<cmd>let @+ = expand("%:p")<cr>')
