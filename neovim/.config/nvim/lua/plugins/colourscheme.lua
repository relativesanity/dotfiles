return {
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "akinsho/bufferline.nvim",
    -- TODO: Remove this once https://github.com/LazyVim/LazyVim/pull/6354 is merged
    init = function()
      local bufline = require("catppuccin.groups.integrations.bufferline")
      bufline.get = bufline.get_theme
    end,
    ---@module 'bufferline'
    ---@type bufferline.Config
  },
}
