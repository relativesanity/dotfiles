-- leader must be set before keymaps load (init.lua requires keymaps before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- fixes checkhealth till we need these
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- UI / behaviour
vim.opt.mouse = "nvi" -- mouse in normal, visual, insert
vim.opt.autoread = true -- re-read the buffer if it's edited elsewhere
vim.opt.clipboard = "unnamedplus" -- sync register with the system clipboard
vim.opt.colorcolumn = "80,100" -- show columns at 80 and 100 chars
vim.opt.cursorline = true -- highlight the current line
vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- relative line numbers for easy jumping
vim.opt.scrolloff = 8 -- keep 8 lines of context above/below cursor
vim.opt.signcolumn = "yes" -- always reserve space for signs
vim.opt.splitbelow = true -- split below instead of above
vim.opt.splitright = true -- split right instead of left
vim.opt.termguicolors = true -- enable 24-bit colours
vim.opt.undofile = true -- store undo history across sessions
vim.opt.wrap = false -- don't wrap lines

-- indentation: two spaces, no tab characters
vim.opt.autoindent = true -- carry indent onto a new line
vim.opt.expandtab = true -- spaces, not tabs
vim.opt.shiftround = true -- round indent to a multiple of shiftwidth
vim.opt.shiftwidth = 2 -- two-space indent steps
vim.opt.smartindent = true -- clever autoindenting
vim.opt.smarttab = true -- a tab in an indent inserts shiftwidth spaces
vim.opt.softtabstop = 2 -- a tab key feels like two spaces while editing
vim.opt.tabstop = 2 -- a tab renders as two spaces

-- search
vim.opt.incsearch = true -- search incrementally while typing
vim.opt.ignorecase = true -- case-insensitive search…
vim.opt.smartcase = true -- …unless the query contains uppercase
