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
require("lazy").setup(LazyRockSpecs, {
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "tokyonight-night" },
	},
	ui = {
		border = "rounded",
	},
	performance = {
		rtp = {
			paths = {
				vim.g.rocks_nvim.rtp_path,
			},
		},
	},
})
