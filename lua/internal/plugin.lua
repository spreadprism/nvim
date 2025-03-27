local M = {}
local specs = require("internal.specs")

local function faster_get_path(name)
	local path = vim.tbl_get(package.loaded, "nixCats", "pawsible", "allPlugins", "opt", name)
	if path then
		vim.cmd.packadd(name)
		return path
	end
	return nil -- nil will make it default to normal behavior
end

---packadd + after/plugin
---@type fun(names: string[]|string)
local load_w_after_plugin = require("lzextras").make_load_with_afters({ "plugin" }, faster_get_path)

---@class Plugin
---@field name string
---@field require_name string
---@field opts_table table
Plugin = {}
Plugin.__index = Plugin

function M.plugin(name)
	local plugin =
		specs.init(name, { name = name, require_name = name, opts_table = {}, load = load_w_after_plugin }, Plugin)
	return plugin:on_require(name)
end

---@param enabled boolean | fun():boolean
---@return Plugin
function Plugin:enabled(enabled)
	specs.apply(self.name, { enabled = enabled })
	return self
end

---@param env string | string[]
---@return Plugin
function Plugin:envPresent(env)
	specs.apply(self.name, {
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

---@param beforeAll fun(Plugin)
---@return Plugin
function Plugin:beforeAll(beforeAll)
	specs.apply(self.name, { beforeAll = beforeAll })
	return self
end

---@param before fun(Plugin)
---@return Plugin
function Plugin:before(before)
	specs.apply(self.name, { before = before })
	return self
end

---@param after? fun(Plugin)
---@return Plugin
function Plugin:after(after)
	if after == nil then
		after = function() end
	end
	specs.apply(self.name, { after = after })
	return self
end

---@param for_cat string
---@return Plugin
function Plugin:for_cat(for_cat)
	specs.apply(self.name, { for_cat = for_cat })
	return self
end

---@param priority number
---@return Plugin
function Plugin:priority(priority)
	specs.apply(self.name, { priority = priority })
	return self
end

---@param lazy boolean
---@return Plugin
function Plugin:lazy(lazy)
	specs.apply(self.name, { lazy = lazy })
	return self
end

---@param event string | string[]
---@return Plugin
function Plugin:event(event)
	specs.apply(self.name, { event = event })
	return self
end

function Plugin:triggerUI()
	return self:event("DeferredUIEnter")
end

function Plugin:triggerBuffer()
	return self:event("BufEnter")
end

---@param cmd string[]
---@return Plugin
function Plugin:cmd(cmd)
	specs.apply(self.name, { cmd = cmd })
	return self
end

---@param ft string | string[]
---@return Plugin
function Plugin:ft(ft)
	specs.apply(self.name, { ft = ft })
	return self
end

---@param keys string | string[] | table
---@return Plugin
function Plugin:keys(keys)
	specs.apply(self.name, { keys = keys })
	return self
end

---@param dep_of string | string[]
---@return Plugin
function Plugin:dep_of(dep_of)
	specs.apply(self.name, { dep_of = dep_of })
	return self
end

---@param on_plugin string | string[]
---@return Plugin
function Plugin:on_plugin(on_plugin)
	specs.apply(self.name, { on_plugin = on_plugin })
	return self
end

---@param on_require string
---@return Plugin
function Plugin:on_require(on_require)
	self.require_name = on_require
	self:opts(self.opts_table)
	specs.apply(self.name, { on_require = on_require })
	return self
end

---@param func fun(keymap: Keymap)
---@return Plugin
function Plugin:keymap(func)
	local keymap = setmetatable({}, require("internal.keymap").Keymap)
	keymap.plugin = self
	func(keymap)
	return self
end

---@param func fun(name: string)
---@return Plugin
function Plugin:load(func)
	specs.apply(self.name, { load = func })
	return self
end

---@param opts table
---@return Plugin
function Plugin:opts(opts)
	self.opts_table = opts
	return self:after(function()
		require(self.require_name).setup(opts)
	end)
end

return M
