local M = {}

local lua_dir_path = vim.g.configs.lua_directory_name
local fs = require("utils.filesystem")

---@param module string
---@return table
M.submodules = function(module)
	module = module:gsub("%.", "/")
	local module_path = vim.fs.joinpath(lua_dir_path, module)
	if not fs.is_dir(module_path) then
		return {}
	end

	local files = fs.get_files(module_path, 1, "lua")
	local submodules = {}
	for _, file in ipairs(files or {}) do
		local submodule = fs.file_name(file, false)
		table.insert(submodules, submodule)
	end
	return submodules
end

return M
