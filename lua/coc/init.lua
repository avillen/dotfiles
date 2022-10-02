-- TextEdit might fail if hidden is not set.
vim.opt.hidden = true

-- Some servers have issues with backup files, see #649.
vim.opt.backup = false
vim.opt.writebackup = false

-- Give more space for displaying messages.
vim.opt.cmdheight = 2

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 300

-- Don't pass messages to |ins-completion-menu|.
vim.o.shortmess = vim.o.shortmess .. "c"

-- Extensions
vim.g.coc_global_extensions = {
  "coc-elixir",
  "coc-go",
  "@yaegassy/coc-tailwindcss3"
}


-- Insert <tab> when previous text is space, refresh completion if not.
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

local opts = {silent = true, noremap = true, expr = true}

vim.api.nvim_set_keymap("i", "<CR>",
                        [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]], opts)

vim.api.nvim_set_keymap("i", "<TAB>",
                        'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
vim.api.nvim_set_keymap("i", "<S-TAB>",
                        [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- GoTo code navigation.
local keyset = vim.keymap.set

keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

vim.cmd [[
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>
]]

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
