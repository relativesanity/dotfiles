vim.lsp.config("ruby_lsp", {
  cmd = { "ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
})
vim.lsp.enable("ruby_lsp")

vim.diagnostic.config({ virtual_text = true })
