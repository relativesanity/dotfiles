return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ruby_lsp",
      },
    },
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("lspconfig").lua_ls.setup({})
          require("lspconfig").ruby_lsp.setup({})
        end,
      },
      {
        "williamboman/mason.nvim",
        opts = {},
      },
    }
  }
}
