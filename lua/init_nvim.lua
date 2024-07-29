vim.g.mapleader = " "
vim.wo.number = true
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showtabline = 0
vim.o.scl = "yes"
vim.o.timeout = true
vim.o.timeoutlen = 200
vim.opt.splitright = true

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end -- TODO: Remove this when v12 is more mature
vim.cmd("silent !mkdir " .. vim.fs.joinpath(vim.fn.stdpath("data"), "dashboard"))

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyVimStarted",
	once = true,
	callback = function()
		local ok, _ = pcall(require, "at_start")
		require("init_local_project")
	end,
})
