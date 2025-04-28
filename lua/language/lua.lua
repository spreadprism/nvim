if not nixCats("language.lua") then
	return
end
formatter("lua", "stylua")

local paths = {
	vim.env.VIMRUNTIME,
	(nixCats.nixCatsPath or "") .. "/lua",
}
local s = vim.split(cwd(), "/", { trimempty = true })
if s[#s] ~= "nvim" then
	table.insert(paths, (nixCats.configDir or "") .. "/lua/internal")
end
lsp("lua_ls"):root_markers(
	".luarc.json",
	".luarc.jsonc",
	".luacheckrc",
	".stylua.toml",
	"stylua.toml",
	"selene.toml",
	"selene.yml",
	".nvim.lua",
	".git"
):settings({
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

plugin("lazydev"):ft("lua"):opts({
	library = vim.list_extend(paths, {}),
	integrations = {
		cmp = false,
	},
})
