return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    -- The markdown extra lints with markdownlint-cli2. Obsidian does that job,
    -- so run no linter here. A function, because an empty table in a plain
    -- opts merge can't be told apart from "nothing to change".
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
    end,
  },
}
