-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight text range when yanked",
  -- this group ensures that if it gets reassigned, it overwrites
  -- whatever was there initially
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})
