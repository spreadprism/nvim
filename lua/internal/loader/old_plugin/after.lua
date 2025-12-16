local M = {}

---@param plugin Plugin
local function config(plugin) end

---@param plugin Plugin
local function setup(plugin)
	local ok, module = pcall(require, plugin.name)

	if not ok then
		return
	end

	local opts = plugin._opts

	if type(opts.setup) == "boolean" and not opts.setup then
		return
	end

	if type(opts) == "nil" then
		opts = {}
	elseif type(opts) == "function" then
		opts = opts()
	end

	if module.setup then
		module.setup(opts)
	end
end

---@param plugin Plugin
M.after = function(plugin)
	setup(plugin)
	config(plugin)
end

return M
