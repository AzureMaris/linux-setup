vim.g.mapleader = " "

vim.o.wrap = false

vim.o.tabstop = 3
vim.o.softtabstop = 3
vim.o.shiftwidth = 3
vim.o.expandtab = true

vim.o.clipboard = "unnamedplus"

vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.list = true
local whitespace = "·"

vim.opt.listchars:append({
   tab = "│─",
   multispace = whitespace,
   lead = whitespace,
   trail = whitespace,
   nbsp = whitespace,
})

vim.diagnostic.config({
   virtual_text = true,
   signs = true,
   underline = true,
})
