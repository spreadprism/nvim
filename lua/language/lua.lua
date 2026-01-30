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
			globals = {
				"nixCats",
				"lsp",
				"plugin",
			},
			disable = { "missing-fields", "different-requires" },
		},
		telemetry = { enabled = false },
	},
})

local opt_plugins = nixCats.pawsible.allPlugins.opt
local start_plugins = nixCats.pawsible.allPlugins.start

local all_plugins = vim.list_extend(start_plugins, opt_plugins)
local names = {}
for k, _ in pairs(all_plugins) do
	table.insert(names, k)
end

plugin("lazydev"):ft("lua"):opts({
	library = names,
	integrations = {
		cmp = false,
	},
})
