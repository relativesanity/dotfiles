vim.lsp.config("ruby_lsp", {
  cmd = { "ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
})
vim.lsp.enable("ruby_lsp")

-- Tailwind class completions. Markers are checked as paths relative to each
-- ancestor rather than via root_markers, because a nested marker there resolves
-- the root to the marker's own directory (config/, not the project root) and
-- Tailwind then resolves its content globs from the wrong place.
local tailwind_markers = {
  "tailwind.config.js",
  "tailwind.config.cjs",
  "tailwind.config.mjs",
  "tailwind.config.ts",
  "config/tailwind.config.js", -- tailwindcss-rails 3.x
  "app/assets/tailwind", -- tailwindcss-rails 4.x, config lives in CSS
}

vim.lsp.config("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "eruby", "css", "scss", "javascriptreact", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then return end
    for dir in vim.fs.parents(path) do
      for _, marker in ipairs(tailwind_markers) do
        if vim.uv.fs_stat(dir .. "/" .. marker) then return on_dir(dir) end
      end
    end
  end,
  settings = {
    tailwindCSS = {
      -- without this the server treats .html.erb as an unknown filetype and
      -- returns nothing at all
      includeLanguages = { eruby = "html" },
      validate = true,
    },
  },
})
vim.lsp.enable("tailwindcss")

-- Emmet abbreviations as completion items, so `div.card>ul>li*3` resolves in the
-- same menu as everything else. No project root is needed — it works per-file,
-- so root_dir is just the file's own directory.
--
-- No Homebrew formula exists, so it's declared in node/.default-npm and
-- installed globally by `dot env` rather than by `dot pack`.
vim.lsp.config("emmet_language_server", {
  cmd = { "emmet-language-server", "--stdio" },
  filetypes = { "html", "eruby", "css", "scss", "javascriptreact", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path ~= "" then on_dir(vim.fs.dirname(path)) end
  end,
})
vim.lsp.enable("emmet_language_server")

vim.diagnostic.config({ virtual_text = true })
