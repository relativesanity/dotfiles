return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>",              desc = "Find files" },
    { "<leader>fo", "<cmd>Telescope oldfiles hidden=true only_cwd=true<cr>",  desc = "Find recent files" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                           desc = "Find help" },
    { "<leader>fs", "<cmd>Telescope live_grep hidden=true<cr>",               desc = "Find via grep search" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                             desc = "Find open buffers" },
    { "<leader>ft", "<cmd>Telescope builtin<cr>",                             desc = "Find telescope features" },
    { "<leader>fe", "<cmd>Telescope file_browser hidden=true<cr>",            desc = "Find via explorer" },
    { "<leader>fr", "<cmd>Telescope file_browser hidden=true path=%:p:h<cr>", desc = "Reveal via explorer" },
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        ".git/",
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        local telescope = require("telescope")
        telescope.load_extension("fzf")
        telescope.setup({
          extensions = {
            fzf = {}
          }
        })
      end,
    },
    {
      "nvim-telescope/telescope-file-browser.nvim",
      config = function()
        local telescope = require("telescope")
        telescope.load_extension("file_browser")
        telescope.setup({
          extensions = {
            file_browser = {}
          }
        })
      end,
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
      config = function()
        local telescope = require("telescope")
        telescope.load_extension("ui-select")
        telescope.setup({
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown {}
            }
          }
        })
      end,
    },
  },
}
