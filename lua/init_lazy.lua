local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
local lazy_specs = require("internal.lazy_specs")
lazy_specs.init_specs()
lazy_specs.read_configs()
require("lazy").setup(lazy_specs.get_specs(), {
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "tokyonight-night" },
	},
	ui = {
		border = "rounded",
	},
	rocks = {
		hererocks = true,
	},
})
