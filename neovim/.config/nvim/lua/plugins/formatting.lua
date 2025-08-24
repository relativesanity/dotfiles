return {
  -- Disable format on save but keep conform.nvim enabled for manual formatting
  {
    "LazyVim/LazyVim",
    opts = {
      -- disable format on save
      format = {
        enabled = false,
      },
    },
  },
}