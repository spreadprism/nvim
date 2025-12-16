local M = {}

local lze = require("internal.loader.plugin.lze")

---@class PluginSpec
---@field name string The plugin's name (not the module name, and not the url). This is the directory name of the plugin in the packpath and is usually the same as the repo name of the repo it was cloned from.
---@field enabled? boolean | fun():boolean When false, or if the function returns nil or false, then this plugin will not be included in the spec.
---@field beforeAll? fun(PluginSpec) Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.
---@field before? fun(PluginSpec) Executed before a plugin is loaded.
---@field after? fun(PluginSpec) Executed after a plugin is loaded.
---@field load? fun(PluginSpec) Custom load function. If provided, this function is called instead of the default loading mechanism.
---@field event? string | {event?:string|string[], pattern?:string|string[]} | string[] Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.
---@field cmd? string | string[] Lazy-load on command.
---@field ft? string | string[] Lazy-load on filetype.
---@field keys? string | string[] Lazy-load on keymap.
---@field colorscheme? string | string[] Lazy-load on colorscheme.
---@field dep_of? string | string[] Lazy-load before another plugin but after its before hook.
---@field on_plugin? string | string[] Lazy-load after another plugin but before its after hook.
---@field on_require? string | string[] Accepts a top-level lua module name or a list of top-level lua module names. Will load when any submodule of those listed is required
M.PluginSpec = {}
M.PluginSpec.__index = M.PluginSpec

---@param name string
---@return PluginSpec
function M.NewPluginSpec(name)
	return setmetatable({
		name = name,
	}, M.PluginSpec)
end

---@class PluginSpecFactory
---@field name string The plugin's name
M.Plugin = {}
M.Plugin.__index = M.Plugin

---@param name string The plugin's name
function M.NewPluginFactory(name)
	return setmetatable({ name = name }, M.Plugin):on_require(name)
end

---@param enabled boolean | fun():boolean
---@return PluginSpecFactory
function M.Plugin:enabled(enabled)
	lze.apply({ name = self.name, enabled = enabled })
	return self
end

return M
