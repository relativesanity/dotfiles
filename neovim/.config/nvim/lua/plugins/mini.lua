return {
  "echasnovski/mini.nvim",
  version = false, -- track main (echasnovski keeps it stable)
  config = function()
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()

    require("mini.statusline").setup({ use_icons = true })
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.splitjoin").setup()
    require("mini.operators").setup()
    require("mini.diff").setup()
    require("mini.git").setup()
    require("mini.trailspace").setup()
    require("mini.cmdline").setup()

    require("mini.notify").setup()
    vim.notify = MiniNotify.make_notify()

    require("mini.ai").setup()
    MiniAi.config.custom_textobjects = {
      -- treesitter method/class/block objects (queries from nvim-treesitter-textobjects).
      c = MiniAi.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      o = MiniAi.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
      -- keyed m because mini.ai's builtin f is already a function *call*.
      m = MiniAi.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    }

    require("mini.hipatterns").setup()
    MiniHipatterns.config.highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      hex_color = MiniHipatterns.gen_highlighter.hex_color(), -- #rrggbb shown in its colour
    }

    require("mini.bracketed").setup()
    -- allow ' and \ as alternatives for [ and ] on my Voyager
    vim.keymap.set({ "n", "x", "o" }, "'", "[", { remap = true })
    vim.keymap.set({ "n", "x", "o" }, "\\", "]", { remap = true })

    require("mini.pick").setup()
    require("mini.extra").setup() -- extra pickers: oldfiles, git, lsp, diagnostic, …
    vim.keymap.set("n", "<leader><leader>", function() MiniPick.builtin.files() end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", function() MiniExtra.pickers.oldfiles() end, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fj", function() MiniExtra.pickers.buf_lines({ scope = "current" }) end, { desc = "Jump to line" })
  end,
}
