local M = {}

---@param plugin Plugin
M.before = function(plugin)
	if plugin._opts.init then
		plugin._opts.init()
	end
end

return M
