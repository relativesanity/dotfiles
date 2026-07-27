return {
  "echasnovski/mini.nvim",
  version = false, -- track main (echasnovski keeps it stable)
  -- Community snippet collection, data only (no lua). Must be on the runtimepath
  -- rather than lazy-loaded, since gen_loader.from_lang() finds it by globbing rtp.
  -- ESCAPE HATCH: delete this line to drop back to just snippets/eruby.json.
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()

    require("mini.statusline").setup({ use_icons = true })
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.splitjoin").setup()
    -- cr/cx free up gr* for LSP keymaps and gx for the builtin open-URL
    require("mini.operators").setup({ replace = { prefix = "cr" }, exchange = { prefix = "cx" } })
    require("mini.diff").setup()
    require("mini.git").setup()
    require("mini.trailspace").setup()
    require("mini.cmdline").setup()

    require("mini.notify").setup()
    vim.notify = MiniNotify.make_notify()

    -- Snippets from snippets/<lang>.json beside this config. Emmet covers markup
    -- but structurally can't emit erb blocks: it rewrites every | into its cursor
    -- marker, so `do |item|` is unexpressible. <C-j> expands, <C-l>/<C-h> jump.
    local snippets = require("mini.snippets")
    -- from_lang() keys off the *treesitter* language under the cursor, which in a
    -- .html.erb buffer is html (or ruby inside <% %>) and never eruby — so
    -- eruby.json needs its own filetype-gated loader to load at all.
    local erb = snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/eruby.json")
    local by_lang = snippets.gen_loader.from_lang()
    -- Inside class="…" the treesitter *language* is still html, so language-keyed
    -- snippets cheerfully offer tag snippets (`p`, `div`) where only a class name
    -- is valid. Only the node type separates them. ignore_injections=false is
    -- required: without it erb reports the outer embedded_template node instead
    -- of the injected html one, and the check silently never fires.
    local function in_attribute_value()
      local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
      if not ok or node == nil then return false end
      local t = node:type()
      return t == "attribute_value" or t == "quoted_attribute_value"
    end
    snippets.setup({
      snippets = {
        function(context)
          if in_attribute_value() then return {} end
          local out = { by_lang(context) }
          if vim.bo[context.buf_id].filetype == "eruby" then table.insert(out, erb(context)) end
          return out
        end,
      },
    })
    -- Serve the loaded snippets as an in-process LSP source so they land in the
    -- same menu as ruby_lsp instead of needing their own key. match=false hands
    -- filtering to the completion engine, which is what mini.completion expects.
    snippets.start_lsp_server({ match = false })

    require("mini.completion").setup()
    -- Supertab: cycle the popup if one is open, else jump to the next snippet
    -- placeholder if a session is live, else insert a literal Tab. Popup is
    -- checked first so completing *inside* a placeholder still works.
    -- <C-l>/<C-h> stay bound to the jumps too, for when a popup is in the way.
    local function supertab(pum_key, direction, fallback)
      return function()
        if vim.fn.pumvisible() == 1 then return pum_key end
        if MiniSnippets.session.get() ~= nil then
          return "<Cmd>lua MiniSnippets.session.jump('" .. direction .. "')<CR>"
        end
        return fallback
      end
    end
    vim.keymap.set("i", "<Tab>", supertab("<C-n>", "next", "<Tab>"), { expr = true })
    vim.keymap.set("i", "<S-Tab>", supertab("<C-p>", "prev", "<S-Tab>"), { expr = true })

    require("mini.ai").setup()
    MiniAi.config.custom_textobjects = {
      -- treesitter method/class/block objects (queries from nvim-treesitter-textobjects).
      c = MiniAi.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      o = MiniAi.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
      -- keyed m because mini.ai's builtin f is already a function *call*.
      m = MiniAi.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    }

    require("mini.hipatterns").setup()
    MiniHipatterns.config.highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      hex_color = MiniHipatterns.gen_highlighter.hex_color(), -- #rrggbb shown in its colour
    }

    require("mini.bracketed").setup()
    -- allow ' and \ as alternatives for [ and ] on my Voyager
    vim.keymap.set({ "n", "x", "o" }, "'", "[", { remap = true })
    vim.keymap.set({ "n", "x", "o" }, "\\", "]", { remap = true })

    require("mini.pick").setup()
    require("mini.extra").setup() -- extra pickers: oldfiles, git, lsp, diagnostic, …
    vim.keymap.set("n", "<leader><leader>", function() MiniPick.builtin.files() end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", function() MiniExtra.pickers.oldfiles() end, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fj", function() MiniExtra.pickers.buf_lines({ scope = "current" }) end, { desc = "Jump to line" })
  end,
}
