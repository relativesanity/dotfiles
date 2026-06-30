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
  -- Textobjects supplies the @function/@class/@parameter/@block queries. Their
  -- *selection* is wired through mini.ai (see plugins/mini.lua); here we add the
  -- plugin's own movement and swap features. Pure Lua, no build step.
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    -- Install any missing parsers (no-op for ones already present).
    require("nvim-treesitter").install(ensure)

    -- Highlighting is a Neovim feature; start it for any buffer whose
    -- filetype has a parser available. pcall keeps filetypes without a
    -- parser (zsh, ghostty, …) on the classic regex syntax instead of erroring.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then return end
        -- vim's indenters need vim syntax, which treesitter highlighting replaces
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        -- ruby's '.'/':'' indentkeys retrigger treesitter mid-chain and dedent to col 0
        local ft = vim.bo[args.buf].filetype
        if ft == "ruby" or ft == "eruby" then
          vim.opt_local.indentkeys:remove({ ".", ":" })
        end
      end,
    })

    require("nvim-treesitter-textobjects").setup()
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")
    local map = vim.keymap.set

    -- Jump between method and class boundaries (works in n/x/o modes).
    map({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next method start" })
    map({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev method start" })
    map({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next method end" })
    map({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Prev method end" })
    map({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
    map({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Prev class start" })

    -- Swap an argument with its neighbour (great for reordering method params).
    map("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "Swap arg with next" })
    map("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap arg with prev" })
  end,
}
