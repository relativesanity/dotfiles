return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
    messages = { enabled = false },
    notify = { enabled = false },
  },
	depedencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
}
