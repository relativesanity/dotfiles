require('rspec').setup()

vim.keymap.set('n', '<leader>rs', vim.cmd.RSpecCurrentFile)
vim.keymap.set('n', '<leader>rn', vim.cmd.RSpecNearest)
