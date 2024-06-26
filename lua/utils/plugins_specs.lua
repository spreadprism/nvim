local M = {}
local fs = require("utils.filesystem")
local mod_utils = require("utils.module")

local configs_directory_name = "configs"
local keybinds_directory_name = "keybinds"
local config_lua_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua")

local configs_directory = vim.fs.joinpath(config_lua_dir, configs_directory_name)
local keybinds_directory = vim.fs.joinpath(config_lua_dir, keybinds_directory_name)

local __plugin_specs = {}

local possible_file_name = function(plugin_url)
	local split = vim.split(plugin_url, "/")
	local name = split[#split]
	local possible_names = {
		[name] = true,
		[name:gsub(".nvim", "")] = true,
		[name:gsub("%-nvim", "")] = true,
		[name:gsub("nvim%-", "")] = true,
	}
	local name_lower = name:lower()
	if name_lower ~= name then
		possible_names = vim.list_extend(possible_names, {
			[name_lower] = true,
			[name_lower:gsub(".nvim", "")] = true,
			[name_lower:gsub("%-nvim", "")] = true,
			[name_lower:gsub("nvim%-", "")] = true,
		})
	end

	local unique_names = {}
	for key, _ in pairs(possible_names) do
		table.insert(unique_names, key)
	end
	return unique_names
end

local Plugin = {}
Plugin.__index = Plugin

---@param url string | table
---@param specs table | nil
function Plugin.new(url, specs)
	local self = setmetatable({}, Plugin)
	self.is_plugin = true
	self.git_repo_url = url
	self.specs = specs or {}
	table.insert(self.specs, 1, url)
	self.possible_file_name = possible_file_name(url)
	table.insert(__plugin_specs, self)
	return self
end

---@return string
function Plugin:plugin_key()
	return self.git_repo_url
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

---@return table | string
function Plugin:to_lazy_specs()
	self:validate_config()
	self:validate_keys()
	return self.specs
end

function Plugin:validate_config()
	if self.specs.config == nil then
		local config_modules = mod_utils.submodules(vim.g.configs.configs_directory_name)
		for _, name in ipairs(self.possible_file_name) do
			if vim.list_contains(config_modules, name) then
				self.specs.config = function()
					local ok, err = pcall(require, vim.g.configs.configs_directory_name .. "." .. name)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR, { title = "LazyRockSpecs" })
					end
				end
				break
			end
		end
	elseif type(self.specs.config) == "string" then
		local config_name = self.specs.config
		self.specs.config = function()
			if self.specs.opts ~= nil then
				---@diagnostic disable-next-line: param-type-mismatch
				require(config_name).setup(self.specs.opts)
			else
				---@diagnostic disable-next-line: param-type-mismatch
				require(config_name).setup()
			end
		end
	end
end

function Plugin:validate_keys()
	if self.specs.keys == nil then
		local keybind_modules = mod_utils.submodules(vim.g.configs.keybinds_directory_name)
		for _, name in ipairs(self.possible_file_name) do
			if vim.list_contains(keybind_modules, name) then
				self.specs.keys = function()
					local ok, err = pcall(require, vim.g.configs.keybinds_directory_name .. "." .. name)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR, { title = "LazyRockSpecs" })
					end
				end
				break
			end
		end
	end
end

M.Plugin = Plugin.new

M.init_lazy_rock_specs = function()
	__plugin_specs = {}
end

local convert_plugins_to_lazy_spec

---@param plugins table
---@return table
convert_plugins_to_lazy_spec = function(plugins)
	local lazy_specs = {}
	if type(plugins) == "table" then
		for _, p in ipairs(plugins) do
			if type(p) == "table" then
				local ok, specs = pcall(Plugin.to_lazy_specs, p)
				if ok then
					table.insert(lazy_specs, specs)
				else
					table.insert(lazy_specs, convert_plugins_to_lazy_spec(p))
				end
			elseif type(p) == "string" then
				table.insert(lazy_specs, p)
			end
		end
	end
	return lazy_specs
end
M.validate_lazy_rock_specs = function()
	if __plugin_specs == nil then
		error("LazyRockSpecs is not initialized")
	end

	LazyRockSpecs = convert_plugins_to_lazy_spec(__plugin_specs)
	-- print(LazyRockSpecs)
end

---@param spec table
M.insert_in_spec = function(spec)
	table.insert(__plugin_specs, spec)
end

return M
