-- taken from Teej's Advent of Neovim
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<cr>")
vim.keymap.set("n", "<leader>x", ":.lua<cr>")
vim.keymap.set("v", "<leader>x", ":lua")

-- navigate the quickfix
vim.keymap.set("n", "<leader>cn", "<cmd>cnext<cr>")
vim.keymap.set("n", "<leader>cp", "<cmd>cprev<cr>")

-- pop a terminal
vim.keymap.set("n", "<leader>t", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)
end)
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>")
