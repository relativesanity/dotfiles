return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls"
      },
    },
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("lspconfig").lua_ls.setup({})
        end,
      },
      {
        "williamboman/mason.nvim",
        opts = {},
      },
    }
  }
}
