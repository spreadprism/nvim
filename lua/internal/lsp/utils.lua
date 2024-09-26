local M = {}

M.default_on_attach = function(client, bufnr)
	-- INFO: Opens floating diagnostic
	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			}
			vim.diagnostic.open_float(nil, opts)
		end,
	})
end

M.default_capabilities = function(lsp_name)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	return capabilities
end

---@type Lsp[]
local all_lsp_configs = {}
---@type table[Lsp, boolean]
local initialized_servers = {}

---@param lsp Lsp
M.insert = function(lsp)
	table.insert(all_lsp_configs, lsp)
end

---@param lsp Lsp
M.configure_lsp_server = function(lsp)
	local configure = function()
		if not initialized_servers[lsp.lsp_name] and lsp.setup_cond() then
			require("lspconfig")[lsp.lsp_name].setup(lsp.opts)
		end
	end
	local ok, _ = pcall(configure)
	if ok then
		initialized_servers[lsp.lsp_name] = true
	else
		vim.notify("Failed to setup " .. lsp.lsp_name, vim.log.levels.WARNING, { title = "LspConfig" })
	end
end

M.configure_all_lsp = function()
	for _, lsp in ipairs(all_lsp_configs) do
		if lsp.setup_cond() then
			if lsp.register_func then
				lsp.register_func()
			end
			M.configure_lsp_server(lsp)
		end
	end
end

M.get_display = function(lsp_name)
	for _, lsp in ipairs(all_lsp_configs) do
		if lsp.lsp_name == lsp_name and lsp.display_var ~= nil then
			return lsp.display_var()
		end
	end
	return nil
end

M.all_lsp_mason = function()
	local lsp_install = {}
	for _, lsp in ipairs(all_lsp_configs) do
		local cond = lsp.auto_install_cond
		if type(cond) == "function" then
			cond = cond() ---@type boolean
		end

		if cond then
			table.insert(lsp_install, lsp.mason_name)
		end
	end
	return lsp_install
end

return M
