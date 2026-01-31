lsp("lua_ls"):root_markers({
	".luarc.json",
	".luarc.jsonc",
	".luacheckrc",
	".stylua.toml",
	"stylua.toml",
	"selene.toml",
	"selene.yml",
	".nvim.lua",
	".git",
}):settings({
	Lua = {
		runtime = { version = "LuaJIT" },
		formatters = {
			ignoreComments = true,
		},
		signatureHelp = { enabled = true },
		diagnostics = {
			globals = vim.list_extend({
				"nixCats",
				"internal",
			}, vim.tbl_keys(internal)),
			disable = { "missing-fields", "different-requires" },
		},
		telemetry = { enabled = false },
	},
})

plugin("lazydev"):ft("lua"):opts({
	library = vim.tbl_values(vim.list_extend(nixCats.pawsible.allPlugins.start, nixCats.pawsible.allPlugins.opt)),
	integrations = {
		cmp = false,
	},
})
