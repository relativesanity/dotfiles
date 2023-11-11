-- ensure lazy plugin manager is installed
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath, })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins
local plugins = {

  -- things which don't have any config up front
  'nvim-tree/nvim-web-devicons', -- for use by nvim-tree, gitsigns etc
  'nvim-tree/nvim-tree.lua', -- tree file browser
  'nvim-lualine/lualine.nvim', -- statusline
  'lewis6991/gitsigns.nvim', -- git gutter indicators
  'lukas-reineke/indent-blankline.nvim', -- show tab guides in blank lines
  'mbbill/undotree', -- navigation for changes
  'johnfrankmorgan/whitespace.nvim', -- show and manage whitespace

  -- pope is god. wait…
  'tpope/vim-sleuth', -- detect tabstop and shiftwidth
  'tpope/vim-commentary', -- enable simple commenting
  'tpope/vim-ragtag', -- provide awesome tag completions
  'tpope/vim-surround', -- enable smart surrounds
  'tpope/vim-rails', -- enable rails stuff
  'github/copilot.vim', -- ai pair programming

  -- pair up quotes, braces etc
  { 'windwp/nvim-autopairs', opts = {} },

  -- catppuccin for theme
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },

  -- treesitter for syntax highlighting
  { 'nvim-treesitter/nvim-treesitter' },

  -- telescope for fuzzy finding
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      }
    }
  },

  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },

}

-- actually load the plugins
require('lazy').setup(plugins, opts)
