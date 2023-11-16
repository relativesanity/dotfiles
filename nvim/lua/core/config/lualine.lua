require('lualine').setup({
  -- options = { },
  sections = {
    lualine_x = { 'filetype' },
  },
  extensions = {
    'nvim-tree', 'mason', 'lazy', 'quickfix'
  }
})
