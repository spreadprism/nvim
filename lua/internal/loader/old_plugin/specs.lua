local M = {}

local load = require("internal.loader.plugin.load").load_w_after_plugin
local before = require("internal.loader.plugin.before").before
local after = require("internal.loader.plugin.after").after

local lze = require("internal.loader.plugin.lze")
---
---@param plugin Plugin
local function apply_plugin(plugin)
	lze.apply(
		plugin.name,
		vim.tbl_deep_extend("keep", {
			name = nil,
			plugin_opts = nil,
		}, plugin)
	)
	return plugin
end

---@class PluginOpts
---@field dependency string[]
---@field config? boolean | fun(Plugin)
---@field init? function
---@field setup? boolean | function
---@field opts? boolean | table | fun(): table
---@field module_name? string
M.PluginOpts = {}
M.PluginOpts.__index = M.PluginOpts

function M.new_opts()
	return setmetatable({}, M.PluginOpts)
end

---@class Plugin
---@field name string
---@field _opts PluginOpts
---@field before fun()
---@field after fun()
M.Plugin = {}
M.Plugin.__index = M.Plugin

---@param name string
---@return Plugin
function M.new_plugin(name)
	local plugin = setmetatable({
		name = name,
		_opts = M.new_opts(),
		load = load,
	}, M.Plugin)

	plugin.before = function()
		before(plugin)
	end

	plugin.after = function()
		after(plugin)
	end

	return apply_plugin(plugin)
end

--- When false, or if the function returns nil or false,
--- then this plugin will not be included in the spec.
---@param enabled boolean | fun():boolean
---@return Plugin
function M.Plugin:enabled(enabled)
	lze.apply(self.name, { enabled = enabled })
	return self
end

--- enable condition based on the presence of the passed
--- environment variables
---@param ... string
---@return Plugin
function M.Plugin:env_enabled(...)
	local env = { ... }
	lze.apply(self.name, {
		enabled = function()
			for _, v in ipairs(env) do
				if vim.fn.empty(vim.fn.getenv(v)) == 0 then
					return true
				end
			end
		end,
	})
	return self
end

--- Lazy-load on event.
--- Events can be specified as BufEnter or with a pattern
--- like BufEnter *.lua
---@param ...  string
function M.Plugin:event(...)
	lze.apply(self.name, { event = { ... } })
	return self
end

function M.Plugin:deferred()
	return self:event("DeferredUIEnter")
end

--- Lazy-load on command
---@param ... string
function M.Plugin:cmd(...)
	lze.apply(self.name, { cmd = { ... } })
	return self
end

--- Lazy-load on filetype
---@param ... string
function M.Plugin:ft(...)
	lze.apply(self.name, { ft = { ... } })
	return self
end

---@param opts? boolean | table | fun(): table
function M.Plugin:opts(opts)
	self._opts.opts = opts
	return self
end

---@param init function
function M.Plugin:init(init)
	self._opts.init = init
	return self
end

---@param setup function
function M.Plugin:setup(setup)
	self._opts.setup = setup
	return self
end

---@param config boolean | fun(Plugin: any)?
function M.Plugin:config(config)
	self._opts.config = config
	return self
end

--- Lazy-load before another plugin but after
--- its `before` hook
---@param ... string
function M.Plugin:dep_of(...)
	lze.apply(self.name, { dep_of = { ... } })
	return self
end

---@param ... string
function M.Plugin:dep_on(...)
	local name = { ... }
	for _, n in ipairs(name) do
		lze.apply(n, { dep_of = { self.name } })
	end
	return self
end

--- Lazy-load after another plugin but before its `after` hook
---@param ... string
function M.Plugin:on_plugin(...)
	lze.apply(self.name, { on_plugin = { ... } })
	return self
end

--- Will load when any submodule of listed name is `require`d
---@param ... string
function M.Plugin:on_require(...)
	local name = { ... }
	lze.apply(self.name, { on_require = name })
	return self
end

return M
