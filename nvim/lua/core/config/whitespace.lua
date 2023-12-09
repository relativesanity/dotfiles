local ws = require('whitespace-nvim')

ws.setup({
  highlight = 'DiffDelete',
  ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help' },
  ignore_terminal = true,
})

-- remove trailing whitespace with a keybinding
vim.keymap.set('n', '<Leader>w', ws.trim, { desc = '(W)hitespace trim' })
