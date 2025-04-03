---@param plugin Plugin
local function after_keymap(plugin)
	-- TODO: implement
end

---@param plugin Plugin
local function after_event(plugin)
	-- TODO: implement
end

---@param plugin Plugin
local function extra_setup(plugin)
	if plugin.plugin_opts.setup then
		plugin.plugin_opts.setup()
	end
end
---@param plugin Plugin
local function after_setup(plugin)
	local config = plugin.plugin_opts.config
	if not config and type(config) == "boolean" then
		return
	end
	if config and type(config) == "function" then
		return plugin.plugin_opts.config(plugin)
	end

	---@param names string[]
	---@return boolean, table
	local try_all = function(names)
		for _, name in ipairs(names) do
			local ok, module = pcall(require, name)
			if ok then
				return true, module
			end
		end
		return false, {}
	end
	local setup = function(module, opts)
		if module.setup then
			if opts or opts == nil then
				if type(opts) == "function" then
					opts = opts()
				end
				module.setup(opts or {})
			else
				module.setup()
			end
		end
	end

	local name = plugin.name
	name = string.gsub(name, "nvim%-", "")
	name = string.gsub(name, "vim%-", "")
	name = string.gsub(name, "%-nvim", "")
	name = string.gsub(name, "%-vim", "")
	name = string.gsub(name, "%.nvim", "")
	name = string.gsub(name, "%.vim", "")

	local pass = { plugin.name, name, unpack(plugin.plugin_opts.possible_names or {}) }
	local found, module = try_all(pass)
	if found then
		setup(module, plugin.plugin_opts.opts)
		return
	else
		vim.print("Unable to require: " .. plugin.name)
		vim.print(pass)
	end
end

---@param plugin Plugin
return function(plugin)
	after_setup(plugin)
	extra_setup(plugin)
	after_event(plugin)
end
