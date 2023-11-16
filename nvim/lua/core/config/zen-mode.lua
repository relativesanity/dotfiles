require('zen-mode').setup({
  window = {
    width = 107,
  },
})

vim.keymap.set('n', '<leader>zm', vim.cmd.ZenMode)
