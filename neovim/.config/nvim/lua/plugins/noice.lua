return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    messages = { enabled = false },
    notify = { enabled = false },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
