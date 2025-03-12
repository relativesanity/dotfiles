return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function ()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'lua',
        'ruby',
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
    vim.filetype.add({
      filename = {
        ['Brewfile'] = 'ruby'
      }
    })
  end,
}
