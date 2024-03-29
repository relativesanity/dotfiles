return {
  "vim-test/vim-test",
  config = function()
    vim.keymap.set("n", "<leader>rn", ":TestNearest<CR>", { desc = "(R)un (n)earest test" })
    vim.keymap.set("n", "<leader>rf", ":TestFile<CR>", { desc = "(R)un test (f)ile" })
    vim.keymap.set("n", "<leader>ra", ":TestSuite<CR>", { desc = "(R)un (a)ll tests" })

    vim.g["test#strategy"] = "vimux"
  end
}
