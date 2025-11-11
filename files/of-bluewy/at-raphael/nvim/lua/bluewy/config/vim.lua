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

vim.diagnostic.config(
   --- @type vim.diagnostic.Opts
   {
      virtual_text = true,
      signs = true,
      underline = true,
   }
)

-- mappings: movement
--
vim.keymap.set("n", "<A-u>", "<Up>", { noremap = true, silent = true, desc = "up" })
vim.keymap.set("n", "<A-i>", "<Right>", { noremap = true, silent = true, desc = "right" })
vim.keymap.set("n", "<A-e>", "<Down>", { noremap = true, silent = true, desc = "bottom" })
vim.keymap.set("n", "<A-n>", "<Left>", { noremap = true, silent = true, desc = "left" })

vim.keymap.set("n", "<C-A-u>", "<C-w>k", { noremap = true, silent = true, desc = "focus upper pane" })
vim.keymap.set("n", "<C-A-i>", "<C-w>l", { noremap = true, silent = true, desc = "focus right pane" })
vim.keymap.set("n", "<C-A-e>", "<C-w>j", { noremap = true, silent = true, desc = "focus bottom pane" })
vim.keymap.set("n", "<C-A-n>", "<C-w>h", { noremap = true, silent = true, desc = "focus left pane" })

-- mappings: resizing
--
vim.keymap.set("n", "<C-A-S-u>", "<cmd>resize -1<CR>", { noremap = true, silent = true, desc = "resize pane up" })

vim.keymap.set(
   "n",
   "<C-A-S-i>",
   "<cmd>vertical resize -1<CR>",
   { noremap = true, silent = true, desc = "resize pane right" }
)

vim.keymap.set("n", "<C-A-S-e>", "<cmd>resize +1<CR>", { noremap = true, silent = true, desc = "resize pane down" })

vim.keymap.set(
   "n",
   "<C-A-S-n>",
   "<cmd>vertical resize +1<CR>",
   { noremap = true, silent = true, desc = "resize pane left" }
)

-- mappings: utility
--
vim.keymap.set(
   "n",
   "<leader>ttw",
   "<cmd>%s/\\s\\+$//e<CR>",
   { noremap = true, silent = true, desc = "trim trailing whitespace" }
)

vim.keymap.set("n", "<leader>tlw", function()
   vim.o.wrap = not vim.o.wrap
   if vim.o.wrap then
      vim.o.linebreak = true
      vim.o.breakindent = true
      print("line wrapping enabled")
   else
      vim.o.linebreak = false
      vim.o.breakindent = false
      print("line wrapping disabled")
   end
end, { noremap = true, silent = true, desc = "toggle line wrapping" })

-- mappings: other
--
vim.keymap.set("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- mappings: lsp
--
vim.keymap.set(
   "n",
   "<leader>of",
   vim.diagnostic.open_float,
   { noremap = true, silent = true, desc = "open float diagnostics" }
)

vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true, desc = "go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "hover" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { noremap = true, silent = true, desc = "go to implementation" })

vim.keymap.set(
   "n",
   "<leader>ls",
   vim.lsp.buf.signature_help,
   { noremap = true, silent = true, desc = "show signature help" }
)

vim.keymap.set(
   "n",
   "<leader>D",
   vim.lsp.buf.type_definition,
   { noremap = true, silent = true, desc = "go to type definition" }
)

vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "refactor rename" })

vim.keymap.set(
   "n",
   "<leader>ca",
   vim.lsp.buf.code_action,
   { noremap = true, silent = true, desc = "show code actions" }
)

vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true, desc = "go to references" })
