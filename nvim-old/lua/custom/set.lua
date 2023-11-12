-- show linenumbers
vim.opt.number = true
-- … sign gutters
vim.opt.signcolumn = 'yes'
-- … and relative line numbers for easier jumping
vim.opt.relativenumber = true

-- you're right Ray; no _human_ would split panes like this
vim.opt.splitbelow = true
vim.opt.splitright = true

-- smartly use tabs to indent in files
vim.opt.smartindent = true
-- … and good god spaces, not tabs
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- line wraps are for word processors
vim.opt.wrap = false

-- set long-running undo
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

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

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- space seems to be popular for leader these days
vim.g.mapleader = " "