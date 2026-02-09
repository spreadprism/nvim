formatter("lua", "stylua")
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
		workspace = {
			library = {
				vim.env.VIMRUNTIME,
			},
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

plugin("lazydev"):ft("lua"):opts(function()
	local libs = {}
	local plugins = nixCats.pawsible.allPlugins
	for _, v in pairs(plugins.start) do
		table.insert(libs, v)
	end
	for _, v in pairs(plugins.opt) do
		table.insert(libs, v)
	end
	return {
		library = libs,
		integrations = {
			cmp = false,
		},
	}
end)
