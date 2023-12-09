vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local ufo = require('ufo')

-- Using ufo provider requires remapping zR and zM
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zk', ufo.peekFoldedLinesUnderCursor)
ufo.setup({
  provider_selector = function(_, _, _)
    return { 'treesitter', 'indent' }
  end
})
