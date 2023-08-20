local builtin = require('telescope.builtin')
pcall(require('telescope').load_extension, 'fzf')
vim.keymap.set('n', '<leader>sf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ss', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
