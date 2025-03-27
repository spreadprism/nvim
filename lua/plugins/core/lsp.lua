---@param server_name string
local function get_capabilities(server_name)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	return capabilities
end

local function on_attach(_, bufnr) end

require("lze").load({
	"nvim-lspconfig",
	for_cat = "core",
	on_require = { "lspconfig" },
	lsp = function(plugin)
		require("lspconfig")[plugin.name].setup(vim.tbl_extend("force", {
			capabilities = get_capabilities(plugin.name),
			on_attach = on_attach,
		}, plugin.lsp or {}))
	end,
})
