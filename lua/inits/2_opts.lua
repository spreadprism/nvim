vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.wo.number = true
vim.o.cmdheight = 0

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

vim.o.swapfile = false

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Cmd>noh<CR>", true, false, true), "n", false)
	end,
})

-- exrc workspace files
vim.g.workspace_file_name = ".nvim.lua"
vim.opt.exrc = true
vim.opt.secure = true

vim.api.nvim_create_autocmd("User", {
	pattern = "DeferredUIEnter",
	callback = function()
		require("internal.shada")
	end,
})
