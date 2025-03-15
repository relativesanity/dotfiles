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

          -- apply lsp formatting on save
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client then return end

              if client.supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = args.buf,
                  callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                  end
                })
              end
            end
          })
        end,
      },
      {
        "williamboman/mason.nvim",
        opts = {},
      },
    }
  }
}
