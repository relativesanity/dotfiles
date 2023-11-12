local plugins = {
  -- catpuccin for theme
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },

  -- devicons for lualine and nvim-tree
  { 'nvim-tree/nvim-web-devicons' },
  -- statusline awesomeness
  { 'nvim-lualine/lualine.nvim' },
  -- filetree
  { 'nvim-tree/nvim-tree.lua' },
  -- telescope for file navmgation
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  -- treesitter for parsing and syntax highlighting
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }
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
