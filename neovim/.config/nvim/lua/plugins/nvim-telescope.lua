return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
  },
  opts = {
    extensions = {
      fzf = {}
    }
  },
  init = function()
    require("telescope").load_extension("fzf")
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files" },
    { "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<cr>", desc = "Find recent files" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",              desc = "Find help" },
    { "<leader>fg", "<cmd>Telescope live_grep hidden=true<cr>",  desc = "Find via grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                desc = "Find open buffers" },
    { "<leader>ft", "<cmd>Telescope builtin<cr>",                desc = "Find telescope features" },
  }
}
