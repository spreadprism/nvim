local M = {}

M.assert_name_unique = function()
	local new_configs = {}

	for _, config in ipairs(require("dap").configurations) do
		new_configs[config.name] = config
	end

	new_configs = {}
	for _, config in ipairs(new_configs) do
		table.insert(new_configs, config)
	end

	require("dap").configurations = new_configs
end

---@param path string | nil
M.load_vscode = function(path)
	require("dap.ext.vscode").load_launchjs(path, {
		codelldb = { "rust", "c" },
	})
	M.assert_name_unique()
end

return M
