local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Misc
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.scrolloff = 8
opt.wrap = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
