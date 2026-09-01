return {
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      float = { transparent = true },
    },
    -- catppuccin's own colorscheme loader can fire before this opts-driven
    -- setup() does, self-initialising with defaults first — so apply the
    -- colorscheme here too, after setup(), instead of leaving it to LazyVim.
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
