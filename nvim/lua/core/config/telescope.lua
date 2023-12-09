local builtin = require('telescope.builtin')
require('telescope').load_extension('fzf')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '(F)ind (f)iles' })
vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = '(F)ind by (s)earch' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '(F)ind open (b)uffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '(F)ind in (h)elp' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '(F)ind in (o)ld files' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = '(F)ind (c)ommands' })

vim.keymap.set('n', '<leader>fg', builtin.git_commits, { desc = '(F)ind (g)it commits' })
