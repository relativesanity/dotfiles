-- mini.nvim — a library of small, independent modules.
-- We opt into only the modules we want; the rest add no startup cost.
-- Add further modules (mini.surround, mini.ai, mini.pairs, …) one at a time.
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
