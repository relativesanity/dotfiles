return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.html.setup({ capabilities = capabilities, filetypes = { "eruby", "html" } })
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.ruby_lsp.setup({ capabilities = capabilities })
      lspconfig.tailwindcss.setup({ capabilities = capabilities })

      vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { desc = "(L)sp (h)over" })
      vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "(L)sp (d)efinition" })
      vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "(L)sp (D)eclaration" })
      vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "(L)sp (i)mplementation" })
      vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, { desc = "(L)sp (t)ype definition" })
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { desc = "(L)sp (r)eferences" })
      vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "(L)sp (s)ignature help" })
      vim.keymap.set("n", "<leader>lm", vim.lsp.buf.rename, { desc = "(L)sp rena(m)e" })
      vim.keymap.set(
        { "n", "x" },
        "<leader>lF",
        "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
        { desc = "(L)sp (F)ormat" }
      )
      vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "(L)sp code (a)ction" })

      vim.keymap.set("n", "<leader>lf", vim.diagnostic.open_float, { desc = "(L)sp open (f)loat" })
      vim.keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, { desc = "(L)sp (p)revious" })
      vim.keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, { desc = "(L)sp (n)ext" })
    end,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = {
          "stylua",
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html",
          "lua_ls",
          "ruby_lsp",
          "tailwindcss",
        },
      })
    end,
    dependencies = { "williamboman/mason-lspconfig.nvim" },
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.rubocop,
          null_ls.builtins.diagnostics.rubocop,
        },
      })
    end,
  },
}
