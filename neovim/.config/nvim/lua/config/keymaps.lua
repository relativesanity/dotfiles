-- quickfix navigation
vim.keymap.set("n", "<leader>cn", "<cmd>cnext<cr>")
vim.keymap.set("n", "<leader>cp", "<cmd>cprev<cr>")

-- lazy
vim.keymap.set("n", "<leader>ll", "<cmd>Lazy<cr>")

-- pop a terminal in a predictable spot (bottom split, 15 rows)
vim.keymap.set("n", "<leader>t", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)
end)
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>") -- escape terminal mode
