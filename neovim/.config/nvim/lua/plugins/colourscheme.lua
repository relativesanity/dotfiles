-- Both schemes are installed; the active one is chosen in config/init.lua.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      integrations = {
        mini = { enabled = true }, -- themes mini.statusline, mini.pick et al.
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
    "RRethy/nvim-base16",
    priority = 1000,
  },
}
