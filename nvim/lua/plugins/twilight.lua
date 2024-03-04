return {
  "folke/twilight.nvim",
  keys = {
    { '<leader>zt', vim.cmd.Twilight, desc = '(z)oom via (t)wilight' }
  },
  opts = {
    dimming = {
      alpha = 0.6
    }
  }
}
