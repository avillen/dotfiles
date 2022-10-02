vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- General
  use('morhetz/gruvbox')
  use('kyazdani42/nvim-tree.lua')
  use('kyazdani42/nvim-web-devicons')
  use('airblade/vim-gitgutter')
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use('SirVer/ultisnips')
  use('honza/vim-snippets')
  use('folke/which-key.nvim')
  use('voldikss/vim-floaterm')

  -- Telescope
  use({'nvim-treesitter/nvim-treesitter', run = ":TSUpdate"})
  use({'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}}})
  use({'kelly-lin/telescope-ag', requires = {{ "nvim-telescope/telescope.nvim" }}})
  use('fannheyward/telescope-coc.nvim')

  -- coc
  use({'neoclide/coc.nvim', branch = 'release'})
  use('elixir-lsp/coc-elixir', {['do'] = 'yarn install && yarn prepack'})
  use('yaegassy/coc-tailwindcss3', {['do'] = 'yarn install --frozen-lockfile'})

  use('tpope/vim-fugitive')
  use('shumphrey/fugitive-gitlab.vim')
  use('tpope/vim-rhubarb')

  -- Elixir
  use('elixir-editors/vim-elixir')

  -- Go
  use('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })

  -- Ruby
  use('vim-ruby/vim-ruby')
  use('tpope/vim-rails')

  -- Systems
  use('hashivim/vim-terraform')
end)
