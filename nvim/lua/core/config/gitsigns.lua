require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Actions
    vim.keymap.set('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = '(G)it (B)lame line' })
    vim.keymap.set('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = '(G)it (T)oggle (B)lame line' })
    vim.keymap.set('n', '<leader>gtd', gs.toggle_deleted, { desc = '(G)it (T)oggle (D)eleted lines' })
  end
})
