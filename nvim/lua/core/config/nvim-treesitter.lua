require 'nvim-treesitter.configs'.setup {
  ensure_installed = {'lua', 'ruby', 'css', 'vim', 'vimdoc'},
  sync_install = false,
  auto_install = true,
  indent = { enable = true, },
  highlight = { enable = true, },
}

-- workaround dot indentation issue
-- see here: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
vim.cmd('autocmd FileType ruby setlocal indentkeys-=.')
