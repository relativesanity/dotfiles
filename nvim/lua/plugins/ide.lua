return {
  -- lsp
  { 'neovim/nvim-lspconfig' },             -- lsp configurations
  { 'williamboman/mason.nvim' },           -- manage lsp installation
  { 'williamboman/mason-lspconfig.nvim' }, -- connect mason and lspconfig
  -- completion
  { 'hrsh7th/nvim-cmp' },                  -- enable completions
  { 'hrsh7th/cmp-nvim-lsp' },              -- connect lsp with completion
  { 'saadparwaiz1/cmp_luasnip' },          -- snippet completions
  { 'hrsh7th/cmp-buffer' },                -- buffer completions
  { 'hrsh7th/cmp-path' },                  -- path completions
  { 'hrsh7th/cmp-cmdline' },               -- command line completions
  -- snippets
  { 'L3MON4D3/LuaSnip' },                  -- snippet engine
  { 'rafamadriz/friendly-snippets' },      -- a bunch of handy snippets
}
