local M = {}

local function faster_get_path(name)
	local path = vim.tbl_get(package.loaded, "nixCats", "pawsible", "allPlugins", "opt", name)
	if path then
		vim.cmd.packadd(name)
		return path
	end
	return nil -- nil will make it default to normal behavior
end

---@type fun(names: string[]|string)
M.load_w_after_plugin = require("lzextras").make_load_with_afters({ "plugin" }, faster_get_path)

return M
