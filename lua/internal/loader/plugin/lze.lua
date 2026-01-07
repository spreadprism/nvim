local M = {}

---@param specs PluginSpec
function M.apply(specs)
	local merge_specs = vim.tbl_deep_extend("keep", {
		specs.name,
		merge = true,
	}, specs)
	merge_specs.name = nil
	require("lze").load(merge_specs)
end

return M
