vim.opt.mouse = 'nvi'             -- disable mouse clicking in vim

vim.opt.autoread = true           -- read the buffer in case it's edited elsewhere
vim.opt.clipboard = 'unnamed'     -- yank to the system clipboard
vim.opt.colorcolumn = '80,100'    -- show columns at 80 and 100 chars
vim.opt.cursorline = true         -- highlight the current line
vim.opt.number = true             -- show line numbers
vim.opt.relativenumber = true     -- show relative line numbers for easy jumping
vim.opt.scrolloff = 8             -- ensure scrolling moves 8 lines before end of buffer
vim.opt.signcolumn = 'yes'        -- space for signs
vim.opt.splitbelow = true         -- split below instead of above
vim.opt.splitright = true         -- split to the right instead of the left
vim.opt.termguicolors = true      -- enable 24-bit colours
vim.opt.undofile = true           -- store undo history across sessions
vim.opt.wrap = false              -- don't wrap lines

vim.opt.autoindent = true         -- automatically set the indent of a new line
vim.opt.expandtab = true          -- expand tab to spaces
vim.opt.shiftround = true         -- round to shiftwidth for << and >>
vim.opt.shiftwidth = 2            -- number of spaces used for each step of indent
vim.opt.smartindent = true        -- do clever autoindenting
vim.opt.smarttab = true           -- a tab in an indent inserts shiftwidth spaces
vim.opt.tabstop = 2               -- number of spaces a tab stands for

vim.opt.incsearch = true          -- search incrementally while typing
vim.opt.ignorecase = true         -- search is case insensitive…
vim.opt.smartcase = true          -- … unless the search contains Upper Case characters

vim.g.loaded_python3_provider = 0 -- remove python provider
vim.g.loaded_ruby_provider = 0    -- remove ruby provider
vim.g.loaded_node_provider = 0    -- remove node provider
vim.g.loaded_perl_provider = 0    -- remove perl provider
