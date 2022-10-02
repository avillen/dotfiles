vim.g.floaterm_winblend = 9
vim.g.floaterm_position = 'center'
vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8
vim.g.floaterm_borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'}
vim.g.floaterm_opener = 'edit'
vim.g.floaterm_autoinsert = true

vim.cmd[[
hi FloatermBorderNF guibg='#4c556a' guifg='#ABB9CF'
]]

vim.api.nvim_set_keymap("n", "<C-t>", ":FloatermToggle<CR>", {silent = true})
vim.api.nvim_set_keymap("t", "<C-t>", "<C-\\><C-n>:FloatermToggle<CR>", {silent = true})
