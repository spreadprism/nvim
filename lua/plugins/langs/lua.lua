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
formatter("lua", "stylua")
plugin("lazydev.nvim"):on_require("lazydev"):cmd("LazyDev"):ft("lua"):opts({
	library = require("internal.lazydev").paths,
})
