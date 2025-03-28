lsp("lua_ls"):ft("lua"):settings({
	Lua = {
		runtime = { version = "LuaJIT" },
		formatters = {
			ignoreComments = true,
		},
		signatureHelp = { enabled = true },
		diagnostics = {
			globals = { "nixCats", "vim" },
			disable = { "missing-fields" },
		},
		telemetry = { enabled = false },
	},
})
plugin("lazydev.nvim"):on_require("lazydev"):cmd("LazyDev"):ft("lua"):opts({
	library = {
		{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
		{
			words = {
				"nxim",
				"plugin",
				"lsp",
				"keymap",
				"keymapCmd",
				"keymapLoad",
				"keymapGroup",
				"load_all",
				"merge_specs",
			},
			path = (nixCats.configDir or "") .. "/lua/nxim",
		},
	},
})
