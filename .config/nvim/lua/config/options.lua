-- Numbers
vim.o.number = true
vim.o.relativenumber = true
-- Keep sign column always visible
vim.o.signcolumn = "yes"
-- Cursorline
vim.o.cursorline = true
-- Show whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Text wrapping
vim.o.wrap = true
vim.o.breakindent = true
-- Tabstops
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
-- Disable swap files
vim.o.swapfile = false
-- Default border for all floating windows
vim.o.winborder = "rounded"
-- Window splitting
vim.o.splitright = true
vim.o.splitbelow = true
-- Enable mouse support
vim.o.clipboard = "unnamedplus"
-- Save undo history
vim.o.undofile = true
-- Disable paging on startup
vim.o.more = false
-- Ensure intro screen is enabled (remove 'I' flag from shortmess if present)
vim.opt.shortmess:remove("I")
