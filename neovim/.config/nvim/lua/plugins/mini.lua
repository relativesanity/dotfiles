-- mini.nvim — a library of small, independent modules.
-- We opt into only the modules we want; the rest add no startup cost.
return {
  "echasnovski/mini.nvim",
  version = false, -- track main (echasnovski keeps it stable)
  config = function()
    -- Icons: feeds file icons to mini.statusline and mini.pick.
    -- Mock devicons so any plugin expecting nvim-web-devicons gets these.
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()

    -- Statusline (catppuccin-themed via the colorscheme's mini integration)
    require("mini.statusline").setup({ use_icons = true })

    -- Editing belt (all defaults) -----------------------------------------
    require("mini.surround").setup() -- sa/sd/sr add/delete/replace surroundings
    require("mini.ai").setup() -- richer a/i text objects: args, functions, tags…
    require("mini.pairs").setup() -- auto-close brackets and quotes
    require("mini.splitjoin").setup() -- gS toggles a block one-line <-> multi-line
    require("mini.bracketed").setup() -- [b ]b, [q ]q, [d ]d … unimpaired-style motions
    -- Operators: g= evaluate, gx exchange, gm multiply, gr replace, gs sort.
    -- Note: gx shadows the builtin open-URL, and gr will overlap LSP's gr*
    -- mappings once we add ruby-lsp — we'll reconcile that in phase 2.
    require("mini.operators").setup()

    -- Fuzzy picker --------------------------------------------------------
    -- files/grep shell out to ripgrep, which reads $RIPGREP_CONFIG_PATH (set
    -- in .zshrc) — so hidden dotfiles are included and .git is skipped without
    -- any picker-specific config here.
    local pick = require("mini.pick")
    pick.setup()

    local map = vim.keymap.set
    map("n", "<leader>ff", function() pick.builtin.files() end, { desc = "Find files" })
    map("n", "<leader><leader>", function() pick.builtin.files() end, { desc = "Find files" })
    map("n", "<leader>fg", function() pick.builtin.grep_live() end, { desc = "Live grep" })
    map("n", "<leader>fb", function() pick.builtin.buffers() end, { desc = "Buffers" })
    map("n", "<leader>fh", function() pick.builtin.help() end, { desc = "Help tags" })
    map("n", "<leader>fr", function() pick.builtin.resume() end, { desc = "Resume last pick" })
  end,
}
