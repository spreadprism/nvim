---@param plugin Plugin
local function set_options(plugin)
	if plugin.plugin_opts.set_options_g then
		plugin.plugin_opts.set_options_g()
	end
	if plugin.plugin_opts.set_options_o then
		plugin.plugin_opts.set_options_o()
	end
end

local function init(plugin)
	if plugin.plugin_opts.init then
		plugin.plugin_opts.init()
	end
end
---@param plugin Plugin
return function(plugin)
	set_options(plugin)
	init(plugin)
end
