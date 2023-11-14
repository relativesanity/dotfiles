local builtin = require('telescope.builtin')
require('telescope').load_extension('fzf')

vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fs', builtin.live_grep)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
vim.keymap.set('n', '<leader>fc', builtin.commands)

vim.keymap.set('n', '<leader>fgc', builtin.git_commits)
vim.keymap.set('n', '<leader>fch', builtin.command_history)
