---@class Configuration : dap.Configuration
---@field args? string[]
---@field env? table<string, string>
---@field cwd? string

---@class LaunchConfigurator
local LaunchConfigurator = {}
LaunchConfigurator.__index = LaunchConfigurator

---@class LaunchConfiguratorFt<T>
---@field ft string
local LaunchConfiguratorFt = {}
LaunchConfiguratorFt.__index = LaunchConfiguratorFt

---@param ft string
---@overload fun(ft: "go"): LaunchConfiguratorFt<GoConfiguration>
function LaunchConfigurator.__call(ft)
	return setmetatable({ ft = ft }, LaunchConfiguratorFt)
end

---@param ft string
---@param opts table
---@overload fun(lang: "go", opts: GoConfiguration|GoConfiguration[]): dap.Configuration|dap.Configuration[]
function LaunchConfigurator:launch(ft, opts) end

---@param opts T
function LaunchConfiguratorFt:launch(opts)
	return LaunchConfigurator.launch(self.ft, opts)
end

return LaunchConfigurator
