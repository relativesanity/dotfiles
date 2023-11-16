local plugins = {
  -- themes
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  -- statusline awesomeness
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  -- filetree
  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  -- telescope for file navmgation
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },
  -- treesitter for parsing and syntax highlighting
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  -- treesitter context to pin things to the top of the buffer
  'nvim-treesitter/nvim-treesitter-context',
  -- ufo for folding
  { 'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async' },
  -- visualise changes via undo history
  'mbbill/undotree',
  -- show and manage whitespace
  'johnfrankmorgan/whitespace.nvim',
  -- automatically add closing pairs
  'windwp/nvim-autopairs',
  -- show git status in gutter
  'lewis6991/gitsigns.nvim',
  -- show indent guides
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl' },

  -- pope is god. wait…
  'tpope/vim-commentary', -- enable simple commenting
  'tpope/vim-surround',   -- enable smart surrounds
  'tpope/vim-repeat',     -- enable repetition for plugin commands
  'tpope/vim-ragtag',     -- provide awesome tag completions

  -- use emmet for HTML editing
  'mattn/emmet-vim',

  -- use zenmode for distraction free editing
  'folke/zen-mode.nvim',
  -- … and twilight for added focus
  'folke/twilight.nvim',

  -- completion
  'hrsh7th/nvim-cmp',         -- enable completions
  'hrsh7th/cmp-buffer',       -- buffer completions
  'hrsh7th/cmp-path',         -- path completions
  'hrsh7th/cmp-cmdline',      -- command line completions
  'saadparwaiz1/cmp_luasnip', -- snippet completions

  -- snippets
  'L3MON4D3/LuaSnip',             -- snippet engine
  'rafamadriz/friendly-snippets', -- a bunch of handy snippets
  'zbirenbaum/copilot.lua',           -- let's try copilot
  'zbirenbaum/copilot-cmp',       -- expose copilot as a cmp source

  -- LSP config
  'neovim/nvim-lspconfig',             -- lsp configurations
  'williamboman/mason.nvim',           -- manage lsp installation
  'williamboman/mason-lspconfig.nvim', -- connect mason and lspconfig
  'hrsh7th/cmp-nvim-lsp',              -- connect lsp with completion
}
















-- Ensure lazy is installed
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy setup with plugins and options defined above
require('lazy').setup(plugins)
-- load config for plugins
require('core.config')
