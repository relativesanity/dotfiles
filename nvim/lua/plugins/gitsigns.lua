return {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      on_attach = function(_)
        local gs = package.loaded.gitsigns

        -- Actions
        vim.keymap.set('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = '(g)it (b)lame line' })
        vim.keymap.set('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = '(g)it (t)oggle (b)lame line' })
        vim.keymap.set('n', '<leader>gtd', gs.toggle_deleted, { desc = '(g)it (t)oggle (d)eleted lines' })
      end
    })
  end
}
