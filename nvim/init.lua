vim.g.mapleader = ' ' -- set leader to space

vim.opt.cursorline = true -- highlight the current line
vim.opt.autoread = true -- read the buffer in case it's edited elsewhere
vim.opt.number = true -- show line numbers
vim.opt.wrap = false -- don't wrap lines
vim.opt.colorcolumn = '80,100' -- show columns at 80 and 100 chars
vim.opt.scrolloff = 8 -- ensure scrolling moves 8 lines before end of buffer
vim.opt.splitbelow = true -- split below instead of above
vim.opt.splitright = true -- split to the right instead of the left
vim.opt.clipboard = 'unnamed' -- yank to the system clipboard
vim.opt.undofile = true -- store undo history across sessions

vim.opt.tabstop = 2 -- number of spaces a tab stands for
vim.opt.shiftwidth = 2 -- number of spaces used for each step of indent
vim.opt.shiftround = true -- round to shiftwidth for << and >>
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.smarttab = true -- a tab in an indent inserts shiftwidth spaces
vim.opt.autoindent = true -- automatically set the indent of a new line
vim.opt.smartindent = true -- do clever autoindenting
