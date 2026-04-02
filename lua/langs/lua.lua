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

plugin("lazydev")
	:ft("lua")
	:opts(function()
		local paths = {
			vim.env.VIMRUNTIME,
			(nixCats.nixCatsPath or "") .. "/lua",
		}
		local s = vim.split(vim.fn.getcwd(), "/", { trimempty = true })
		if s[#s] ~= "nvim" then
			table.insert(paths, (nixCats.configDir or "") .. "/lua/internal")
		end
		return {
			library = paths,
			integrations = {
				cmp = false,
			},
		}
	end)
	:lazydev({ words = { "lazydev" } })
