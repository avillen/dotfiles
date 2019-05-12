"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets

set nocompatible
set autowrite     " Automatically :write before running commands
set backspace=2   " Backspace deletes like most programs in insert mode
set colorcolumn=+1 " Make it obvious where 80 characters is
set expandtab
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set list listchars=tab:»·,trail:·,nbsp:· " Display extra whitespace
set nojoinspaces  " Use one space, not two, after punctuation.
set nobackup      " No generates .swp files
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set nowritebackup " No generates .swp files
set number relativenumber
set numberwidth=5
set ruler         " show the cursor position all the time
set shiftround
set shiftwidth=2
set showcmd       " display incomplete commands
set splitbelow    " Open new split panes to bottom, which feels more natural
set splitright    " Open new split panes to right, which feels more natural
set tabstop=2
set textwidth=80  " Make it obvious where 80 characters is

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load Plugins

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Style

syntax on
colorscheme desert
filetype plugin indent on

" Set syntax highlighting for specific file types
augroup vimrcEx
  autocmd!
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

let g:is_posix = 1

" Silence bell
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab completion

set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maps

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" vim-test mappings
nnoremap <silent> <Leader>tf :TestFile<CR>
nnoremap <silent> <Leader>t :TestNearest<CR>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Use fzf with CtrlP
map <C-p> :Files<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NerdTree

let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowHidden = 1

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | wincmd p | ene | exe 'NERDTree' argv()[0] | endif

map <C-o> :NERDTreeToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Elixir

let g:mix_format_on_save = 1

