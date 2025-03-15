vim.opt.number = true             -- display line numbers
vim.opt.relativenumber = true     -- use relative line numbers
vim.opt.wrap = false              -- don't wrap text

vim.opt.expandtab = true          -- spaces, not tabs
vim.opt.shiftwidth = 2            -- indentation is 2 spaces
vim.opt.tabstop = 2               -- tabs are two spaces
vim.opt.shiftround = true         -- round to shiftwidth for >> and <<

vim.opt.clipboard = "unnamedplus" -- sync register with the system clipboard

vim.opt.undofile = true           -- store undo history across sessions

vim.opt.splitbelow = true         -- split below instead of above
vim.opt.splitright = true         -- split right instead of left

vim.opt.incsearch = true          -- search incrementally while typing
vim.opt.ignorecase = true         -- search is case insensitive
vim.opt.smartcase = true          -- … unless the search term contains Upper Case
