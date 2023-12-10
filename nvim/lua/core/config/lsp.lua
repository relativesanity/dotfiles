local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function (event)
    vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, { desc = '(L)sp (h)over', buffer = event.buf })
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, { desc = '(L)sp (d)efinition', buffer = event.buf })
    vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, { desc = '(L)sp (D)eclaration', buffer = event.buf })
    vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, { desc = '(L)sp (i)mplementation', buffer = event.buf })
    vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, { desc = '(L)sp (t)ype definition', buffer = event.buf })
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, { desc = '(L)sp (r)eferences', buffer = event.buf })
    vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, { desc = '(L)sp (s)ignature help', buffer = event.buf })
    vim.keymap.set('n', '<leader>lm', vim.lsp.buf.rename, { desc = '(L)sp rena(m)e', buffer = event.buf })
    vim.keymap.set({'n', 'x'}, '<leader>lF', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', { desc = '(L)sp (F)ormat', buffer = event.buf })
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { desc = '(L)sp code (a)ction', buffer = event.buf })

    vim.keymap.set('n', '<leader>lf', vim.diagnostic.open_float, { desc = '(L)sp open (f)loat', buffer = event.buf })
    vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev, { desc = '(L)sp (p)revious', buffer = event.buf })
    vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next, { desc = '(L)sp (n)ext', buffer = event.buf })
  end
})

local default_setup = function (server)
  lspconfig[server].setup({
    capabilities = lsp_capabilities
  })
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'solargraph' },
  handlers = { default_setup }
})

local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config{
  float={border=_border}
}
