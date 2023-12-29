return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      sync_install = false,
      auto_install = true,
      indent = { enable = true, },
      highlight = { enable = true, },
    })
    -- see here: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
    vim.cmd('autocmd FileType ruby setlocal indentkeys-=.')

    -- make zsh files recognized as sh for bash-ls & treesitter
    -- credit to https://nanotipsforvim.prose.sh/treesitter-and-lsp-support-for-zsh
    vim.filetype.add {
      extension = {
        zsh = 'sh',
        sh = 'sh', -- force sh-files with zsh-shebang to still get sh as filetype
      },
      filename = {
        ['.zshrc'] = 'sh',
        ['.zshenv'] = 'sh',
        ['zprofile'] = 'sh', -- add this as it's how I store my dotfile
        ['zshrc'] = 'sh',    -- add this as it's how I store my dotfile
      },
    }
  end
}
