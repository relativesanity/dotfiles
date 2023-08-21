require 'nvim-treesitter.configs'.setup {
  ensure_installed = { 'c', 'lua', 'ruby', 'vim', 'vimdoc', 'query' },
  sync_install = false,
  auto_install = true,
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- workaround dot indentation issue
-- see here: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
vim.cmd('autocmd FileType ruby setlocal indentkeys-=.')
