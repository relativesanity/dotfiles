-- ensure lazy plugin manager is installed
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath, })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins
local plugins = {

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

    { 'folke/which-key.nvim', opts = {} },

    -- catppuccin for theme
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000
    },

    -- treesitter for syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    },

    -- lualine for vim statusline
    {
        'nvim-lualine/lualine.nvim',
        lazy = false,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- gitsigns for showing when I've edited a file
    { 'lewis6991/gitsigns.nvim' },

    -- nvim-tree for browsing files
    {
        'nvim-tree/nvim-tree.lua',
        lazy = false,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('nvim-tree').setup {}
        end,
    },

}

-- actually load the plugins
require('lazy').setup(plugins, opts)
