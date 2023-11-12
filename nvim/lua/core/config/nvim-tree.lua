require('nvim-tree').setup()
-- toggle tree view, opening at current file
vim.keymap.set('n', '<leader>t', vim.cmd.NvimTreeFindFileToggle)
