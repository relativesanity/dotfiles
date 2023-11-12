local plugins = {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }
}

local opts = { }




-- Ensure lazy is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy setup with plugins and options defined above
require("lazy").setup(plugins, opts)
-- load config for plugins
require('core.config')
