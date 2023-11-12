vim.g.mapleader = ' ' -- set leader to space

-- Enables block level line moving in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Shift cursor to start of the line when joining
vim.keymap.set('n', 'J', "mzJ'z")

-- Move cursor to the middle row when paging…
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
-- … and searching
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
