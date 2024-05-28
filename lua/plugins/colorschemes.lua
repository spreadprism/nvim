local transparent = plugin("xiyaowong/transparent.nvim"):event("VeryLazy"):opts({
	extra_groups = { "Notify", "WhichKey", "Telescope" },
	exclude_groups = { "TelescopeSelection", "TelescopePreviewLine" },
})

plugin("folke/tokyonight.nvim"):lazy(false):priority(1000):dependencies(transparent):config("configs.colorscheme")
