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
    config = function()
      -- black-metal comments sit at base03 (#333, invisible on black); base04
      -- (#999) reads too bright, and the palette has no slot between — so this
      -- is a hand-picked grey in that gap. Applied whenever a base16 scheme loads.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "base16-*",
        callback = function()
          vim.api.nvim_set_hl(0, "Comment", { fg = "#555555" })
          vim.api.nvim_set_hl(0, "@comment", { fg = "#555555", italic = true })
        end,
      })
    end,
  },
}
