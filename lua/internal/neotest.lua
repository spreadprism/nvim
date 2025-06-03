local M = {}

local adapters = {}
---@param adapter string
function M.adapter(adapter)
	plugin(adapter):config(false):on_plugin("neotest")
	return function(opts)
		table.insert(adapters, function()
			return require(adapter)(opts)
		end)
	end
end

function M.list_adapters()
	local ans = {}

	for _, adapter in ipairs(adapters) do
		table.insert(ans, adapter())
	end

	return ans
end

return M
