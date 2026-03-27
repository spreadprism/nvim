---
---@generic T
---@class LaunchConfiguratorFt<T>
---@field ft string
local LaunchConfiguratorFt = {}
LaunchConfiguratorFt.__index = LaunchConfiguratorFt

---@class LaunchConfigurator
local LaunchConfigurator = {}
LaunchConfigurator.__index = LaunchConfigurator

---@generic T
---@param ft `T`
---@param opts `T`Configurator | `T`Configurator[]
function LaunchConfigurator:launch(ft, opts)
	return {}
end

---@generic T
---@param opts T | T[]
function LaunchConfiguratorFt:launch(opts)
	return LaunchConfigurator:launch(self.ft, opts)
end

---Create a filetype-specific launch configurator
---@generic T
---@param ft `T`
---@return T
local function new(ft) end

---@param ft string
local function newConfiguration(ft)
	return new(ft)
end

return LaunchConfigurator
