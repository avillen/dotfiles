vim.cmd [[packadd packer.nvim]]


return require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- General
  use('morhetz/gruvbox')
  use('scrooloose/nerdtree')
  use('Xuyuanp/nerdtree-git-plugin')
  use('airblade/vim-gitgutter')
  use('junegunn/fzf', {['do'] = vim.fn['fzf#install']})
  use('junegunn/fzf.vim')
  use('itchyny/lightline.vim')
  use('SirVer/ultisnips')
  use('honza/vim-snippets')

  -- coc
  use('neoclide/coc.nvim', { branch = 'release' })
  use('elixir-lsp/coc-elixir', {['do'] = 'yarn install && yarn prepack'})
  use('yaegassy/coc-tailwindcss3', {['do'] = 'yarn install --frozen-lockfile'})

  use('tpope/vim-fugitive')
  use('shumphrey/fugitive-gitlab.vim')
  use('tpope/vim-rhubarb')

  --------------------------------------------------------------------------------
  -- Elixir
  use('elixir-editors/vim-elixir')

  --------------------------------------------------------------------------------
  -- Go
  use('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })

  --------------------------------------------------------------------------------
  -- Ruby
  use('vim-ruby/vim-ruby')
  use('tpope/vim-rails')

  --------------------------------------------------------------------------------
  -- Systems
  use('hashivim/vim-terraform')
end)
