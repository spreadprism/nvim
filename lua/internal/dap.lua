local M = {}

---@param ft string
function M.clear(ft)
	require("dap").configurations[ft] = {}
end

local adapters = {}

---@param name string
---@param opts table
function M.adapter(name, opts)
	adapters[name] = opts
end

function M.init_adapters()
	local dap = require("dap")
	for name, opts in pairs(adapters) do
		dap.adapters[name] = opts
	end
end

return M
