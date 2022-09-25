vim.cmd [[
  colorscheme gruvbox
  filetype plugin indent on
]]

vim.opt.background = "dark"

vim.g.is_posix = 1

-- Silence bell
vim.cmd [[
  set noerrorbells visualbell t_vb=
  autocmd GUIEnter * set visualbell t_vb=
]]

-- Go syntax highlighting
vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_operators = 1

-- Status line types/signatures
vim.g.go_auto_type_info = 1
