local utils = require("internal.lazy_specs.utils")
local specs = require("internal.lazy_specs.specs")

---@class Plugin
---@field specs table
---@field plugin_url string
---@field possible_names table
---@field is_plugin boolean
local Plugin = {}
Plugin.__index = Plugin

---@param url string
function Plugin.new(url)
	local self = setmetatable({}, Plugin)
	self.is_plugin = true
	self.plugin_url = url
	self.specs = {}
	self.possible_names = utils.generate_possible_names(url)
	table.insert(self.specs, 1, url)
	specs.insert(self)
	return self
end
---@return string
function Plugin:plugin_key()
	return self.plugin_url
end
---@param directory string | nil
function Plugin:dir(directory)
	self.specs.directory = directory
	return self
end
---@param url string | nil
function Plugin:url(url)
	self.specs.url = url
	return self
end
---@param name string | nil
function Plugin:name(name)
	self.specs.name = name
	return self
end
---@param dev boolean | nil
function Plugin:dev(dev)
	self.specs.dev = dev
	return self
end
---@param lazy boolean | nil
function Plugin:lazy(lazy)
	self.specs.lazy = lazy
	return self
end
---@param enabled boolean | nil | fun(): boolean
function Plugin:enabled(enabled)
	self.specs.enabled = enabled
	return self
end
---@param cond boolean | nil | fun(LazyPlugin): boolean
function Plugin:cond(cond)
	self.specs.cond = cond
	return self
end
---@param dependencies string | table
function Plugin:dependencies(dependencies)
	if type(dependencies) == "table" then
		if dependencies.is_plugin or false then
			dependencies = dependencies:plugin_key()
		else
			local temp = {}
			for _, dep in ipairs(dependencies) do
				if type(dep) == "table" and dep.is_plugin or false then
					table.insert(temp, dep:plugin_key())
				else
					table.insert(temp, dep)
				end
			end
			dependencies = temp
		end
	end
	self.specs.dependencies = dependencies
	return self
end
---@param init fun(LazyPlugin)
function Plugin:init(init)
	self.specs.init = init
	return self
end
---@param opts table | string | fun(LazyPlugin, table): table
function Plugin:opts(opts)
	self.specs.opts = opts
	return self
end
---@param config fun(LazyPlugin, table) | true | string | boolean
function Plugin:config(config)
	if type(config) == "string" then
		local config_module = config
		config = function()
			local ok, err = pcall(require, config_module)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR, { title = "LazyRockSpecs" })
			end
		end
		self.specs.config = config
	else
		self.specs.config = config
	end
	return self
end
---@param main string | nil
function Plugin:main(main)
	self.specs.main = main
	return self
end
---@param build fun(LazyPlugin, table) | string
function Plugin:build(build)
	self.specs.build = build
	return self
end
---@param branch string | nil
function Plugin:branch(branch)
	self.specs.branch = branch
	return self
end
---@param tag string | nil
function Plugin:tag(tag)
	self.specs.tag = tag
	return self
end
---@param commit string | nil
function Plugin:commit(commit)
	self.specs.commit = commit
	return self
end
---@param version string | nil | false
function Plugin:version(version)
	self.specs.version = version
	return self
end
---@param pin boolean | nil
function Plugin:pin(pin)
	self.specs.pin = pin
	return self
end
---@param submodules boolean | nil
function Plugin:submodules(submodules)
	self.specs.submodules = submodules
	return self
end
function Plugin:event(event)
	self.specs.event = event
	return self
end
function Plugin:cmd(cmd)
	self.specs.cmd = cmd
	return self
end
function Plugin:ft(ft)
	self.specs.ft = ft
	return self
end
function Plugin:keys(keys)
	self.specs.keys = keys
	return self
end
---@param module false | nil
function Plugin:module(module)
	self.specs.module = module
	return self
end
---@param priority number | nil
function Plugin:priority(priority)
	self.specs.priority = priority
	return self
end
---@param optional boolean | nil
function Plugin:optional(optional)
	self.specs.optional = optional
	return self
end

return Plugin.new
