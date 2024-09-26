local fs = require("internal.fs")
local M = {}

local module_path = function(module)
	return vim.fs.joinpath(LUA_DIRECTORY_PATH, module)
end

M.list_submodules = function(module, depth, append_parent)
	if module == nil then
		return
	end

	depth = depth or 1

	append_parent = append_parent or false

	local submodules = {}

	local files = fs.list_files(module_path(module), depth, "lua")

	for _, file in pairs(files or {}) do
		local submodule = vim.split(file, ".", { plain = true, trimempty = true })[1]
		submodule = submodule:gsub("/", ".")

		if append_parent then
			submodule = module .. "." .. submodule
		end
		table.insert(submodules, submodule)
	end

	return submodules
end

return M
