-- Automatically :write before running commands
vim.opt.autowrite = true     

-- Make it obvious where 80 characters is
vim.opt.colorcolumn = "81"   

-- Break line at 80 chars
vim.opt.textwidth = 80

-- move the cursor to the matched string while searching
vim.opt.incsearch = true

-- replace tabs with spaces
vim.opt.expandtab = true

vim.opt.listchars = {
	tab = '»·',
	trail = '·',
	nbsp = '·'
}

-- No generates .swp files
vim.opt.backup = false

-- No generates .swp files
vim.opt.writebackup = false

-- http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
vim.opt.swapfile = false

vim.opt.compatible = false

-- Use one space, not two, after punctuation.
vim.opt.joinspaces = false

vim.opt.number = true

vim.opt.shiftround = true

vim.opt.shiftwidth = 2

-- display incomplete commands
vim.opt.showcmd = true

-- Open new split panes to bottom, which feels more natural
vim.opt.splitbelow = true

-- Open new split panes to right, which feels more natural
vim.opt.splitright = true

vim.opt.tabstop = 2
