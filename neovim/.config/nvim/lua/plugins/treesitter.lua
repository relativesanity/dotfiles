-- nvim-treesitter (main branch — the rewrite). Core ships parsers for a few
-- filetypes (lua, markdown, vimdoc, query) and auto-starts them; this adds the
-- rest and turns highlighting on for them.
--
-- Parsers to keep installed. Grouped by what they cover in this setup.
local ensure = {
  -- this repo / general config
  "bash", "lua", "vim", "vimdoc", "query",
  "markdown", "markdown_inline",
  "json", "yaml", "toml",
  "git_config", "gitcommit", "gitignore", "diff",
  "ssh_config", "tmux", "regex",
  -- ruby / rails (Brewfile is a ruby DSL; erb views, styling)
  "ruby", "embedded_template", "html", "css", "scss",
  -- javascript / typescript
  "javascript", "typescript", "tsx",
  -- go
  "go", "gomod", "gosum", "gowork",
  -- rust
  "rust",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- load at startup so highlighting is up immediately
  build = ":TSUpdate", -- keep parsers matched to the plugin version
  config = function()
    -- Install any missing parsers (no-op for ones already present).
    require("nvim-treesitter").install(ensure)

    -- Highlighting is a Neovim feature; start it for any buffer whose
    -- filetype has a parser available. pcall keeps filetypes without a
    -- parser (zsh, ghostty, …) on the classic regex syntax instead of erroring.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
