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
    -- mini.ai: richer a/i text objects. Builtins cover args (a), function calls
    -- (f), tags (t), brackets, quotes. The m/c/o objects below are parse-accurate
    -- treesitter ones, reading queries from nvim-treesitter-textobjects:
    --   m = method/function def, c = class/module, o = block (do…end / {…}).
    local ai = require("mini.ai")
    ai.setup({
      custom_textobjects = {
        m = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        o = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
      },
    })
    require("mini.pairs").setup() -- auto-close brackets and quotes
    require("mini.splitjoin").setup() -- gS toggles a block one-line <-> multi-line
    require("mini.bracketed").setup() -- [b ]b, [q ]q, [d ]d … unimpaired-style motions
    -- Also reach the bracketed motions via ' and \ (just below [ and ] on a
    -- normal board; stacked vertically on the Voyager). remap=true so ' behaves
    -- as [ and \ as ], keeping the original [ ] prefixes too. Trade-off: this
    -- shadows ' mark-line jumps — use ` (backtick) for marks instead.
    vim.keymap.set({ "n", "x", "o" }, "'", "[", { remap = true })
    vim.keymap.set({ "n", "x", "o" }, "\\", "]", { remap = true })
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
    -- <leader>fr is intentionally left free for a recents picker in phase 2
    -- (mini.extra oldfiles / mini.visits frecency). Resume is available via :Pick.

    -- Key clues -----------------------------------------------------------
    -- which-key-style popups after a short pause. Triggers pick which prefixes
    -- to watch; gen_clues add descriptions. (' and \ aren't triggers — pressing
    -- [ or ] shows the bracketed clues; the aliases just execute.)
    local clue = require("mini.clue")
    clue.setup({
      triggers = {
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "x", keys = "[" },
        { mode = "x", keys = "]" },
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        { mode = "n", keys = "<C-w>" },
      },
      clues = {
        { mode = "n", keys = "<Leader>f", desc = "+find" },
        clue.gen_clues.g(),
        clue.gen_clues.z(),
        clue.gen_clues.square_brackets(),
        clue.gen_clues.registers(),
        clue.gen_clues.windows(),
        clue.gen_clues.builtin_completion(),
      },
    })

    -- Git -----------------------------------------------------------------
    require("mini.diff").setup() -- gutter signs; gh apply, gH reset, [h ]h hunks
    require("mini.git").setup() -- :Git command, MiniGit.show_at_cursor

    -- Polish --------------------------------------------------------------
    require("mini.trailspace").setup() -- highlight trailing ws; :lua MiniTrailspace.trim()
    local notify = require("mini.notify")
    notify.setup()
    vim.notify = notify.make_notify() -- route vim.notify through the tidy float
    require("mini.cmdline").setup() -- cmdline autocomplete, autocorrect, range peek
  end,
}
