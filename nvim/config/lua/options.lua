local o = vim.opt

o.number = true
o.relativenumber = true
o.cursorline = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.wrap = false
o.mouse = "a"
o.clipboard = "unnamedplus"
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.updatetime = 250
o.timeoutlen = 400
o.showmode = false
o.list = false
o.completeopt = { "menu", "menuone", "noselect" }

-- indentação (herdada do antigo .vimrc)
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- .ll é detectado como "lifelines" por padrão; aqui é LLVM IR
vim.filetype.add({ extension = { ll = "llvm" } })
