local M = {}

local before = require("internal.plugin.before")
local after = require("internal.plugin.after")
local lze = require("internal.plugin.lze")
local load = require("internal.plugin.loader").load_w_after_plugin
---@param plugin Plugin
local function apply_plugin(plugin)
	lze.apply(
		plugin.name,
		vim.tbl_deep_extend("keep", {
			name = nil,
			plugin_opts = nil,
		}, plugin)
	)
end

---@class PluginOps
---@field dependency string[]
---@field config? boolean | fun(Plugin)
---@field init? function
---@field setup? function
---@field opts? boolean | table | fun(): table
---@field set_options_o? function
---@field set_options_g? function
---@field possible_names? string[]
PluginOpts = {}
PluginOpts.__ = PluginOpts

function M.plugin_opts()
	return setmetatable({}, PluginOpts)
end

---@class Plugin
---@field name string
---@field plugin_opts PluginOps
Plugin = {}
Plugin.__index = Plugin

---@param name string
function M.plugin(name)
	local plugin = setmetatable({
		name = name,
		plugin_opts = M.plugin_opts(),
		load = load,
	}, Plugin)
	plugin.after = function()
		after(plugin)
	end
	plugin.before = function()
		before(plugin)
	end
	apply_plugin(plugin)
	return plugin
end

--- When false, or if the function returns nil or false,
--- then this plugin will not be included in the spec.
---@param enabled boolean | fun():boolean
---@return Plugin
function Plugin:enabled(enabled)
	lze.apply(self.name, { enabled = enabled })
	return self
end

--- enable condition based on the presence of the passed
--- environment variables
---@param env string | string[]
---@return Plugin
function Plugin:env_enabled(env)
	lze.apply(self.name, {
		enabled = function()
			env = env
			if type(env) == "string" then
				env = { env }
			end

			for _, v in ipairs(env) do
				if vim.fn.empty(vim.fn.getenv(v)) == 0 then
					return true
				end
			end
		end,
	})
	return self
end

--- A nixCats specific lze handler that you can use to conditionally
--- enable by category easier.
---@param for_cat string
---@return Plugin
function Plugin:for_cat(for_cat)
	lze.apply(self.name, { for_cat = for_cat })
	return self
end

--- Sets vim.g options before a plugin is loaded
---@param options table<string, any>
function Plugin:set_g_options(options)
	self.plugin_opts.set_options_g = function()
		for k, v in pairs(options) do
			vim.g[k] = vim.tbl_deep_extend("force", vim.g[k] or {}, v)
		end
	end
	return self
end
--- Sets vim.o options before a plugin is loaded
---@param options table<string, any>
function Plugin:set_o_options(options)
	self.plugin_opts.set_options_o = function()
		for k, v in pairs(options) do
			vim.o[k] = vim.tbl_deep_extend("force", vim.o[k] or {}, v)
		end
	end
	return self
end

--- Lazy-load on event.
--- Events can be specified as BufEnter or with a pattern
--- like BufEnter *.lua
---@param event string | string[]
function Plugin:event(event)
	lze.apply(self.name, { event = event })
	return self
end

function Plugin:event_ui()
	return self:event("DeferredUIEnter")
end

--- Lazy-load on command
---@param cmd string | string[]
function Plugin:cmd(cmd)
	lze.apply(self.name, { cmd = cmd })
	return self
end

--- Lazy-load on filetype
---@param ft string | string[]
function Plugin:ft(ft)
	lze.apply(self.name, { ft = ft })
	return self
end

--- Lazy-load on keys
---@param keys Keymap[]
function Plugin:keys(keys)
	-- -- TODO: this won't work
	-- local actual_keys = {}
	-- for _, key in ipairs(keys) do
	-- 	table.insert(keys, { key.mode, key.keys, key.action })
	-- end
	--
	--  vim.print(actual_keys)
	-- lze.apply(self.name, { keys = actual_keys })
	return self
end

--- Lazy-load before another plugin but after
--- its `before` hook
---@param name string | string[]
function Plugin:dep_of(name)
	lze.apply(self.name, { dep_of = name })
	return self
end

--- Lazy-load after another plugin but before its `after` hook
---@param name string | string[]
function Plugin:on_plugin(name)
	lze.apply(self.name, { on_plugin = name })
	return self
end

--- Will load when any submodule of listed name is `require`d
---@param name string | string[]
function Plugin:on_require(name)
	if type(name) == "string" then
		name = { name }
	end
	lze.apply(self.name, { on_require = name })
	self.plugin_opts.possible_names = name
	return self
end

---@param opts? boolean | table | fun(): table
function Plugin:opts(opts)
	self.plugin_opts.opts = opts
	return self
end

---@param init function
function Plugin:init(init)
	self.plugin_opts.init = init
	return self
end

---@param setup function
function Plugin:setup(setup)
	self.plugin_opts.setup = setup
	return self
end

---@param config boolean | fun(Plugin: any)?
function Plugin:config(config)
	self.plugin_opts.config = config
	return self
end

return M
