return {
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay1 },
          CursorLineNr = { fg = colors.text },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
