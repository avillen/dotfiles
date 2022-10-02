-- Related to https://github.com/elixir-editors/vim-elixir/issues/562#issuecomment-1092331491
vim.cmd [[
  au BufRead,BufNewFile *.ex,*.exs set filetype=elixir
  au BufRead,BufNewFile *.eex,*.heex,*.leex,*.sface,*.lexs set filetype=eelixir
  au BufRead,BufNewFile mix.lock set filetype=elixir
]]
