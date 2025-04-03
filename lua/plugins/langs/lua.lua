lsp("lua_ls"):settings({
	Lua = {
		runtime = { version = "LuaJIT" },
		formatters = {
			ignoreComments = true,
		},
		signatureHelp = { enabled = true },
		diagnostics = {
			globals = {
				"nixCats",
				"vim",
				"cwd",
				"joinpath",
				"lsp",
				"plugin",
				"keymap",
				"kcmd",
				"keymapLoad",
				"kgroup",
			},
			disable = { "missing-fields", "different-requires" },
		},
		telemetry = { enabled = false },
	},
})
plugin("lazydev.nvim"):on_require("lazydev"):cmd("LazyDev"):ft("lua"):opts({
	library = require("internal.lazydev").paths,
})
formatter("lua", "stylua")
