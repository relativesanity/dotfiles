return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    -- options = { },
    sections = {
      lualine_x = { 'filetype' },
    },
    extensions = {
      'nvim-tree', 'mason', 'lazy', 'quickfix'
    }
  }
}
