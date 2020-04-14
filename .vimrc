"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets

set autowrite      " Automatically :write before running commands
set backspace=2    " Backspace deletes like most programs in insert mode
set colorcolumn=+1 " Make it obvious where 80 characters is
set textwidth=80   " Break line at 80 chars
set incsearch      " move the cursor to the matched string while searching
set expandtab      " replace tabs with spaces
set list listchars=tab:»·,trail:·,nbsp:· " Display extra whitespace
set nobackup       " No generates .swp files
set nowritebackup  " No generates .swp files
set noswapfile     " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set nocompatible
set nojoinspaces   " Use one space, not two, after punctuation.
set number
set shiftround
set shiftwidth=2
set showcmd        " display incomplete commands
set splitbelow     " Open new split panes to bottom, which feels more natural
set splitright     " Open new split panes to right, which feels more natural
set tabstop=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load Plugins

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Style

syntax on
colorscheme gruvbox
set background=dark
filetype plugin indent on

let g:is_posix = 1

" Silence bell
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maps

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Resize
noremap <Up> :resize +5<CR>
noremap <Down> :resize -5<CR>
noremap <Left> :vertical:resize -5<CR>
noremap <Right> :vertical:resize +5<CR>

" Use fzf with CtrlP
map <C-p> :Files<CR>

" Copy current path location
if system('uname') =~ "Linux"
  nmap yp :let @+=expand("%")<CR>
else
  nmap yp :let @*=expand("%")<CR>
endif

" Map :W to :w
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))

" Fugitive
nmap <silent> <leader>gd :Gvdiff<cr>
nmap <silent> <leader>gg :Gbrowse<cr>
xmap <silent> <leader>gg :Gbrowse<cr>
nmap <silent> <leader>gb :Gblame<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NerdTree

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowHidden = 1

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | wincmd p | ene | exe 'NERDTree' argv()[0] | endif

map <C-o> :NERDTreeToggle<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Elixir

let g:mix_format_on_save = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Elm

let g:elm_format_autosave = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UltiSnippet
let g:UltiSnipsSnippetsDir = "~/.snippets/ultisnips"
let g:UltiSnipsSnippetDirectories = ["/home/av/.snippets/ultisnips"]
let g:UltiSnipsExpandTrigger="<leader><tab>"
let g:UltiSnipsJumpForwardTrigger="<leader><tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"

