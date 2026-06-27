return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme "catppuccin-nvim"
    end,
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
}
