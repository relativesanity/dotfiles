local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
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
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
    { 'nvim-lualine/lualine.nvim', lazy = false, dependencies = { 'nvim-tree/nvim-web-devicons' }, },
    { 'lewis6991/gitsigns.nvim' },
    {
        'nvim-tree/nvim-tree.lua', lazy = false, dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('nvim-tree').setup {}
        end,
    },
}

require('lazy').setup(plugins, opts)
