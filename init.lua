-------------------------------------------------------------------------------
-- Sets

vim.opt.autowrite = true     -- Automatically :write before running commands
vim.opt.colorcolumn = "81"   -- Make it obvious where 80 characters is
vim.opt.textwidth = 80       -- Break line at 80 chars
vim.opt.incsearch = true     -- move the cursor to the matched string while searching
vim.opt.expandtab = true     -- replace tabs with spaces
vim.opt.listchars = {
	tab = '»·',
	trail = '·',
	nbsp = '·'
}
vim.opt.backup = false       -- No generates .swp files
vim.opt.writebackup = false  -- No generates .swp files
vim.opt.swapfile = false     -- http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
vim.opt.compatible = false
vim.opt.joinspaces = false   -- Use one space, not two, after punctuation.
vim.opt.number = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.showcmd = true       -- display incomplete commands
vim.opt.splitbelow = true    -- Open new split panes to bottom, which feels more natural
vim.opt.splitright = true    -- Open new split panes to right, which feels more natural
vim.opt.tabstop = 2


-------------------------------------------------------------------------------
-- Load Configs

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.vim/bundle')

-------------------------------------------------------------------------------
-- General
Plug('morhetz/gruvbox')
Plug('scrooloose/nerdtree')
Plug('Xuyuanp/nerdtree-git-plugin')
Plug('airblade/vim-gitgutter')
Plug('junegunn/fzf', {['do'] = vim.fn['fzf#install']})
Plug('junegunn/fzf.vim')
Plug('itchyny/lightline.vim')
Plug('SirVer/ultisnips')
Plug('honza/vim-snippets')

-- coc
Plug('neoclide/coc.nvim', { branch = 'release' })
Plug('elixir-lsp/coc-elixir', {['do'] = 'yarn install && yarn prepack'})
Plug('yaegassy/coc-tailwindcss3', {['do'] = 'yarn install --frozen-lockfile'})

Plug('tpope/vim-fugitive')
Plug('shumphrey/fugitive-gitlab.vim')
Plug('tpope/vim-rhubarb')

-------------------------------------------------------------------------------
-- Elixir
Plug('elixir-editors/vim-elixir')

--------------------------------------------------------------------------------
-- Go
Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })

--------------------------------------------------------------------------------
-- Ruby
Plug('vim-ruby/vim-ruby')
Plug('tpope/vim-rails')

--------------------------------------------------------------------------------
-- Systems
Plug('hashivim/vim-terraform')

vim.call('plug#end')

-- End config
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Coc configuration

vim.opt.hidden = true -- TextEdit might fail if hidden is not set.
vim.opt.backup = false -- Some servers have issues with backup files, see #649.
vim.opt.writebackup = false -- Some servers have issues with backup files, see #649.
vim.opt.cmdheight = 2 -- Give more space for displaying messages.
vim.opt.updatetime = 300 -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
vim.o.shortmess = vim.o.shortmess .. "c" -- Don't pass messages to |ins-completion-menu|.

vim.g.coc_global_extensions = {"coc-elixir", "coc-go", "@yaegassy/coc-tailwindcss3"}

vim.cmd [[
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction
]]

-- Insert <tab> when previous text is space, refresh completion if not.

vim.cmd [[
inoremap <silent><expr> <TAB>
	\ coc#pum#visible() ? coc#pum#next(1):
	\ CheckBackSpace() ? "\<Tab>" :
	\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"
]]

-- GoTo code navigation.
vim.api.nvim_set_keymap("n", "gd", "<Plug>(coc-definition)", { silent = true })
vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.api.nvim_set_keymap("n", "gr", "<Plug>(coc-references)", { silent = true })

vim.cmd [[
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
]]

-- Use K to show documentation in preview window.
vim.api.nvim_set_keymap("n", "K", ":call <SID>show_documentation()<CR>", { noremap = true, silent = true })

vim.cmd [[
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
]]

-- End Coc configuration
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Style

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


-------------------------------------------------------------------------------
-- Maps

-- Switch between the last two files
vim.api.nvim_set_keymap("n", "<Leader><Leader>", "<C-^>", { noremap = true })

-- Quicker window movement
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })

-- Stop highlight when searching
vim.api.nvim_set_keymap("n", "<CR>", ":nohlsearch<CR><CR>", { noremap = true, silent = true })

-- Resize
vim.api.nvim_set_keymap("n", "<Up>", ":resize +5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", ":resize -5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", ":vertical:resize -5<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", ":vertical:resize +5<CR>", { noremap = true })

-- Stop highlight when searching
vim.api.nvim_set_keymap("n", "<CR>", ":nohlsearch<CR><CR>", { noremap = true, silent = true})

-- Use fzf with CtrlP
vim.api.nvim_set_keymap("n", "<C-p>", ":Files<CR>", { noremap = true, silent = true })

-- Copy current path location
vim.api.nvim_set_keymap("n", "yp", ':let @*=expand("%")<CR>', {})

-- Map :W to :w
vim.cmd([[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
]])

-- Fugitive
vim.g.fugitive_gitlab_domains = { "gitlab.otters.xyz" }

vim.api.nvim_set_keymap("n", "<leader>gd", ":Gvdiff<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>gg", ":GBrowse<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("x", "<leader>gg", ":GBrowse<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>gb", ":Git blame<cr>", {noremap = true, silent = true})


-------------------------------------------------------------------------------
-- NerdTree

vim.NERDTreeMinimalUI = 1
vim.NERDTreeDirArrows = 1
vim.NERDTreeShowHidden = 1

vim.cmd([[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | wincmd p | ene | exe 'NERDTree' argv()[0] | endif
]])

vim.api.nvim_set_keymap("n", "<C-o>", ":NERDTreeToggle<CR>", {})


-------------------------------------------------------------------------------
-- Formatters
vim.g.mix_format_on_save = 1
vim.g.terraform_fmt_on_save=1
vim.g.go_fmt_autosave = 1


-------------------------------------------------------------------------------
-- Go syntax highlighting
vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_operators = 1

-- Auto formatting and importing
vim.g.go_fmt_autosave = 1
vim.g.go_fmt_command = "goimports"

-- Status line types/signatures
vim.g.go_auto_type_info = 1


-------------------------------------------------------------------------------
-- UltiSnippet
vim.g.UltiSnipsSnippetsDir = "~/.snippets/ultisnips"
vim.g.UltiSnipsSnippetDirectories = {"/Users/alvarovillen/.snippets/ultisnips"}
vim.g.UltiSnipsExpandTrigger = "<leader><tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<leader><tab>"
vim.g.UltiSnipsJumpBackwardTrigger = "<c-b>"
vim.g.UltiSnipsEditSplit = "vertical"

