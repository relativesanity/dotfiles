return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			ruby = { "rubocop" },
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout = 500,
		},
	},
}
