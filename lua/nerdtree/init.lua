vim.NERDTreeMinimalUI = 1
vim.NERDTreeDirArrows = 1
vim.NERDTreeShowHidden = 1

vim.cmd([[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | wincmd p | ene | exe 'NERDTree' argv()[0] | endif
]])

vim.api.nvim_set_keymap("n", "<C-o>", ":NERDTreeToggle<CR>", {})
