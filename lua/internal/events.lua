local M = {}

--- exec callback when a plugin is loaded
--- ```lua
--- event.on_plugin("nvim-treesitter", function() print("treesitter loaded") end)
---@param name string
---@param callback fun()
---@param group? string|integer
function M.on_plugin(name, callback, group)
	if plugin_loaded(name) then
		callback()
	else
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PluginLoaded",
			callback = function(args)
				if args and args.data and args.data.name == name then
					callback()
				end
			end,
		})
	end
end

---@param pattern string | string[]
---@param callback fun()
---@param group ? string|integer
function M.on_save(pattern, callback, group)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = pattern,
		callback = callback,
	})
end

return M
