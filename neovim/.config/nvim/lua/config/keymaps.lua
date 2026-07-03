-- paste the last yank — register 0 survives deletes, plain p doesn't
vim.keymap.set({ "n", "x" }, "<leader>p", '"0p', { desc = "Paste last yank (after)" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"0P', { desc = "Paste last yank (before)" })

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
