return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons", },
  opts = {
    view = { width = 30, },
    filters = { custom = { "^.git$" } },
  },
  keys = {
    { '<leader>t', vim.cmd.NvimTreeFindFileToggle, desc = '(T)reeview toggle' }
  },
}
