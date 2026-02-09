vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.wo.number = true
vim.o.cmdheight = 0
-- vim.o.cursorline = true
-- vim.o.cursorlineopt = "number"

vim.o.expandtab = true
vim.o.autoindent = true
vim.o.cedit = "<C-r>"
vim.opt.autoread = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showtabline = 0
vim.o.scl = "yes"
vim.o.timeout = true
vim.o.timeoutlen = 200
vim.opt.splitright = true
vim.o.updatetime = 750
vim.opt.undofile = true -- INFO: Save undo history

vim.deprecate = function() end

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})
