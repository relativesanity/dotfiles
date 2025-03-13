return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      preset = {
        header = "Neovim"
      },
      sections = {
        { section = "header" },
        { section = "startup" },
      }
    },
    indent = { enabled = true },
  }
}
