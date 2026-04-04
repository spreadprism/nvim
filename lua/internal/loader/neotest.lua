local M = {}

local adapters = {}

---@param adapter string
---@param is_plugin? boolean
function M.adapter(adapter, is_plugin)
	if is_plugin or is_plugin == nil then
		plugin(adapter):opts(false):on_plugin("neotest")
	end
	return function(opts)
		table.insert(adapters, function()
			return require(adapter)(opts)
		end)
	end
end

function M.adapters()
	local ans = {}

	for _, adapter in ipairs(adapters) do
		table.insert(ans, adapter())
	end

	return ans
end

return M
