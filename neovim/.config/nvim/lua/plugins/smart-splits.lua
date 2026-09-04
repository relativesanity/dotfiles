-- Split focus, tmux-boundary-aware — see ~/.dotfiles/Keybindings.md.
-- Resize is plain vim core (<C-w>+/-/</>), not a smart-splits/tmux-aware
-- binding — see Keybindings.md for why no no-prefix modifier combo worked
-- out for that.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    multiplexer_integration = "tmux",
  },
  config = function(_, opts)
    local smart_splits = require("smart-splits")
    smart_splits.setup(opts)

    for _, key in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
      pcall(vim.keymap.del, "n", key)
    end

    local map = vim.keymap.set
    map("n", "<C-A-h>", smart_splits.move_cursor_left, { desc = "Focus split left" })
    map("n", "<C-A-j>", smart_splits.move_cursor_down, { desc = "Focus split down" })
    map("n", "<C-A-k>", smart_splits.move_cursor_up, { desc = "Focus split up" })
    map("n", "<C-A-l>", smart_splits.move_cursor_right, { desc = "Focus split right" })
  end,
}
