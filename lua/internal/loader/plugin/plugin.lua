local M = {}

local lze = require("internal.loader.plugin.lze")
local load_fn = require("internal.loader.plugin.load").load

---@class PluginSpec
---@field name string The plugin's name (not the module name, and not the url). This is the directory name of the plugin in the packpath and is usually the same as the repo name of the repo it was cloned from.
---@field enabled? boolean | fun():boolean When false, or if the function returns nil or false, then this plugin will not be included in the spec.
---@field for_cat? string Categories this plugin belongs to. Used for filtering which plugins to load.
---@field beforeAll? fun(PluginSpec) Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.
---@field before? fun(PluginSpec) Executed before a plugin is loaded.
---@field after? fun(PluginSpec) Executed after a plugin is loaded.
---@field load? fun(PluginSpec) Custom load function. If provided, this function is called instead of the default loading mechanism.
---@field allow_again? boolean | fun(): boolean When a plugin has ALREADY BEEN LOADED, true would allow you to add it again.
---@field opts? boolean | table | fun(): table
---@field event? string | {event?:string|string[], pattern?:string|string[]} | string[] Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.
---@field cmd? string | string[] Lazy-load on command.
---@field ft? string | string[] Lazy-load on filetype.
---@field keys? string | string[] Lazy-load on keymap.
---@field colorscheme? string | string[] Lazy-load on colorscheme.
---@field dep_of? string | string[] Lazy-load before another plugin but after its before hook.
---@field on_plugin? string | string[] Lazy-load after another plugin but before its after hook.
---@field on_require? string | string[] Accepts a top-level lua module name or a list of top-level lua module names. Will load when any submodule of those listed is required
---@field lazy? boolean Whether the plugin is lazy-loaded or not.
---@field priority? number Load priority. Higher numbers load first (default 50).
---@field _keymaps wk.Spec[] plugin keybindings.
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
	return setmetatable({ name = name }, M.Plugin):on_require(name):load(load_fn)
end

---When false, or if the function returns nil or false, then this plugin will not be included in the spec.
---@param enabled boolean | fun():boolean | any
---@return PluginSpecFactory
function M.Plugin:enabled(enabled)
	lze.apply({ name = self.name, enabled = enabled })
	return self
end

---Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.
---@param hook fun(PluginSpec)
---@return PluginSpecFactory
function M.Plugin:beforeAll(hook)
	lze.apply({ name = self.name, beforeAll = hook })
	return self
end

---Executed before a plugin is loaded.
---@param hook fun(PluginSpec)
---@return PluginSpecFactory
function M.Plugin:before(hook)
	lze.apply({ name = self.name, before = hook })
	return self
end

---Executed after a plugin is loaded.
---@param hook fun(PluginSpec)
---@return PluginSpecFactory
function M.Plugin:after(hook)
	lze.apply({ name = self.name, after = hook })
	return self
end

---Custom load function. If provided, this function is called instead of the default loading mechanism.
---@param fn fun(PluginSpec)
---@return PluginSpecFactory
function M.Plugin:load(fn)
	lze.apply({ name = self.name, load = fn })
	return self
end

---When a plugin has ALREADY BEEN LOADED, true would allow you to add it again. No idea why you would want this outside of testing.
---@param allow boolean | fun(): boolean
---@return PluginSpecFactory
function M.Plugin:allow_again(allow)
	lze.apply({ name = self.name, allow_again = allow })
	return self
end

---Plugin options table or function that returns options.
---@param opts boolean | table | fun(): table
---@return PluginSpecFactory
function M.Plugin:opts(opts)
	lze.apply({ name = self.name, opts = opts })
	return self
end

---Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.
---@param event NvimEvent | NvimEvent[]
---@return PluginSpecFactory
function M.Plugin:event(event)
	lze.apply({ name = self.name, event = event })
	return self
end

---Lazy-load on command.
---@param cmd string | string[]
---@return PluginSpecFactory
function M.Plugin:cmd(cmd)
	lze.apply({ name = self.name, cmd = cmd })
	return self
end

---Lazy-load on filetype.
---@param ft string | string[]
---@return PluginSpecFactory
function M.Plugin:ft(ft)
	lze.apply({ name = self.name, ft = ft })
	return self
end

---plugin keybindings.
---@param mappings Keymap | Keymap[] | fun(): Keymap | fun(): Keymap[]
---@return PluginSpecFactory
function M.Plugin:keymaps(mappings)
	self._keymaps = self._keymaps or {}

	if type(mappings) == "function" then
		mappings = mappings()
	end

	if mappings.__index == nil then
		for _, map in ipairs(mappings) do
			table.insert(self._keymaps, map)
		end
	else
		table.insert(self._keymaps, mappings)
	end

	lze.apply({ name = self.name, keymaps = { self._keymaps } })
	return self
end

---Lazy-load on colorscheme.
---@param colorscheme string | string[]
---@return PluginSpecFactory
function M.Plugin:colorscheme(colorscheme)
	lze.apply({ name = self.name, colorscheme = colorscheme })
	return self
end

---Lazy-load before another plugin but after its before hook.
---@param dep_of string | string[] | PluginSpecFactory | PluginSpecFactory[]
---@return PluginSpecFactory
function M.Plugin:dep_of(dep_of)
	if type(dep_of) == "string" or (type(dep_of) == "table" and dep_of.__index == M.Plugin) then
		dep_of = { dep_of }
	end

	local dep = vim.tbl_map(function(dep)
		return type(dep) == "string" and dep or dep.name
	end, dep_of)
	lze.apply({ name = self.name, dep_of = dep })
	return self
end

---@param dep_on string | string[] | PluginSpecFactory | PluginSpecFactory[]
---@return PluginSpecFactory
function M.Plugin:dep_on(dep_on)
	if type(dep_on) == "string" or (type(dep_on) == "table" and dep_on.__index == M.Plugin) then
		dep_on = { dep_on }
	end

	for _, dep in ipairs(dep_on) do
		local name = type(dep) == "string" and dep or dep.name
		lze.apply({ name = name, dep_of = { self.name } })
	end

	return self
end

---Lazy-load after another plugin but before its after hook.
---@param on_plugin string | string[]
---@return PluginSpecFactory
function M.Plugin:on_plugin(on_plugin)
	lze.apply({ name = self.name, on_plugin = on_plugin })
	return self
end

---Accepts a top-level lua module name or a list of top-level lua module names. Will load when any submodule of those listed is required.
---@param on_require string | string[]
---@return PluginSpecFactory
function M.Plugin:on_require(on_require)
	lze.apply({ name = self.name, on_require = on_require })
	return self
end

---Whether the plugin is lazy-loaded or not.
---@param lazy boolean
---@return PluginSpecFactory
function M.Plugin:lazy(lazy)
	lze.apply({ name = self.name, lazy = lazy })
	return self
end

---Load priority. Higher numbers load first (default 50).
---@param priority number
---@return PluginSpecFactory
function M.Plugin:priority(priority)
	lze.apply({ name = self.name, priority = priority, lazy = false })
	return self
end

function M.Plugin:vim(vim)
	lze.apply({ name = self.name, vim = vim })
	return self
end

---@param fn fun(highlights: tokyonight.Highlights, colors: ColorScheme)
function M.Plugin:on_highlights(fn)
	require("internal.loader.highlight").plugins_highlight(fn)
	return self
end

---@param fn fun(colors: ColorScheme)
function M.Plugin:on_colors(fn)
	require("internal.loader.highlight").plugins_color(fn)
	return self
end

return M
