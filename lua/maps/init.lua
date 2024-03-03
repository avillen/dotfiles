-- Switch between the last two files
vim.api.nvim_set_keymap("n", "<Leader><Leader>", "<C-^>", { noremap = true })

-- Quicker window movement
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })
vim.api.nvim_set_keymap("n", "gn", ":bnext<CR>", {})
vim.api.nvim_set_keymap("n", "gb", ":bprevious<CR>", {})
vim.api.nvim_set_keymap("n", "tn", ":tabnew<CR>", {})
vim.api.nvim_set_keymap("n", "td", ":tabclose<CR>", {})

-- Stop highlight when searching
vim.api.nvim_set_keymap("n", "<CR>", ":nohlsearch<CR><CR>", { noremap = true, silent = true })

-- Resize
vim.api.nvim_set_keymap("n", "<Up>", ":resize +5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", ":resize -5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", ":vertical:resize -5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", ":vertical:resize +5<CR>", { noremap = true })

-- Use Telescope with CtrlP
vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true, silent = true })

-- Copy current path location
vim.api.nvim_set_keymap("n", "yp", ':let @*=expand("%")<CR>', {})

-- Map :W to :w
vim.cmd([[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
]])

-- Fugitive
vim.g.fugitive_gitlab_domains = { "gitlab.otters.xyz" }

vim.api.nvim_set_keymap("n", "<leader>gd", ":Gvdiff<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gg", ":GBrowse<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<leader>gg", ":GBrowse<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gb", ":Git blame<cr>", { noremap = true, silent = true })

-- Vim Test
vim.api.nvim_set_keymap("n", "<leader>t", ":TestNearest<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>T", ":TestFile<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>a", ":TestSuite<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>l", ":TestLast<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>g", ":TestVisit<CR>", { noremap = true, silent = true })

-- Copilot
vim.keymap.set('i', '<C-n>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<C-p>', '<Plug>(copilot-previous)')
