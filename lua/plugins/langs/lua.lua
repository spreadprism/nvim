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

local library = {
	{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
}
if cwd() ~= joinpath(XDG_CONFIG, "nxim") then
	table.insert(library, (nixCats.configDir or "") .. "/lua/internal")
end
plugin("lazydev.nvim"):on_require("lazydev"):cmd("LazyDev"):ft("lua"):opts({
	library = library,
})
