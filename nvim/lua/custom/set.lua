-- show linenumbers
vim.opt.number = true
-- … and relative line numbers for easier jumping
vim.opt.relativenumber = true

-- set some sane tab defaults
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- … make sure they get used
vim.opt.smartindent = true
-- … and good god spaces, not tabs
vim.opt.expandtab = true

-- line wraps are for word processors
vim.opt.wrap = false

-- search incrementally while typing
vim.opt.incsearch = true

-- enable 24-bit colours
vim.opt.termguicolors = true

-- ensure at least 8 lines between the bottom of the screen and file
vim.opt.scrolloff = 8

-- add rules at 80 and 100 cols
vim.opt.colorcolumn = '80,100'
-- … and highlight the current line while we're at it
vim.opt.cursorline = true

-- space seems to be popular for leader these days
vim.g.mapleader = " "
