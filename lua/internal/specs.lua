local M = {}

function M.apply(name, specs)
	local new_specs = vim.tbl_deep_extend("keep", {
		name,
		merge = true,
	}, specs)
	new_specs.name = nil
	new_specs.require_name = nil
	new_specs.opts_table = nil
	-- print(new_specs)
	require("lze").load(new_specs)
end

---@generic T
---@param name string
---@param init table
---@param metatable T
---@return T
function M.init(name, init, metatable)
	local cfg = setmetatable(init, metatable)
	M.apply(name, cfg)
	return cfg
end

function M.merge()
	require("lze").h.merge.trigger()
end

return M
