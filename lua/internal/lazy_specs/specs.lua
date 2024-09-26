local utils = require("internal.lazy_specs.utils")

local M = {}

local __plugin_specs = nil

---@param plugin Plugin | Rock
M.insert = function(plugin)
	if __plugin_specs == nil then
		error("LazyRockSpecs is not initialized")
	end
	table.insert(__plugin_specs, plugin)
end

M.init_plugin_specs = function()
	__plugin_specs = {}
end
local convert_to_lazy_spec
---@param plugins Plugin[]
convert_to_lazy_spec = function(plugins)
	local lazy_specs = {}
	if type(plugins) == "table" then
		for _, p in ipairs(plugins) do
			if type(p) == "table" then
				local ok, specs = pcall(utils.plugin_to_lazy_spec, p)
				if ok then
					table.insert(lazy_specs, specs)
				else
					table.insert(lazy_specs, convert_to_lazy_spec(p))
				end
			elseif type(p) == "string" then
				table.insert(lazy_specs, p)
			end
		end
	end
	return lazy_specs
end

M.specs = function()
	if __plugin_specs == nil then
		error("LazyRockSpecs is not initialized")
	end

	LazyRockSpecs = convert_to_lazy_spec(__plugin_specs)
	return LazyRockSpecs
end
return M
