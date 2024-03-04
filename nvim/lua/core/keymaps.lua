vim.g.mapleader = ' ' -- set leader to space

 -- Enables block level line moving in visual mode
 vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move visual block up' })
 vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move visual block down' })

 -- Move cursor to the middle row when paging…
 vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move cursor down and zoom to line' })
 vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Move cursor up and zoom to line' })

 -- … and searching
 vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Move cursor to next result and zoom to line' })
 vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Move cursor to previous result and zoom to line' })
