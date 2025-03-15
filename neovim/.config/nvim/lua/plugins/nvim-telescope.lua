return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim",  build = "make" },
    { "nvim-telescope/telescope-file-browser.nvim" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        ".git/",
      },
    },
    extensions = {
      fzf = {},
      file_browser = {},
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {}
      },
    }
  },
  init = function()
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("file_browser")
    require("telescope").load_extension("ui-select")
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>",             desc = "Find files" },
    { "<leader>fo", "<cmd>Telescope oldfiles hidden=true only_cwd=true<cr>", desc = "Find recent files" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                          desc = "Find help" },
    { "<leader>fs", "<cmd>Telescope live_grep hidden=true<cr>",              desc = "Find via grep search" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                            desc = "Find open buffers" },
    { "<leader>ft", "<cmd>Telescope builtin<cr>",                            desc = "Find telescope features" },
    { "<leader>fe", "<cmd>Telescope file_browser hidden=true<cr>",           desc = "Find via explorer" },
  }
}
