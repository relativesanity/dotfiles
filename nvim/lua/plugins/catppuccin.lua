return {
	'catppuccin/nvim',
	name = 'catppuccin',
	priority = 1000,
	config = function()
		require('catppuccin').setup({
			flavour = 'mocha', -- latte, frappe, macchiato, mocha
			transparent_background = true,
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { 'italic' }, -- Change the style of comments
			}
		})
		vim.cmd.colorscheme('catppuccin')
	end
}
