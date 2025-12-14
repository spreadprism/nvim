local M = {}

---@class PluginOpts
---@field dependency string[]
---@field config? boolean | fun(Plugin)
---@field init? function
---@field setup? function
---@field opts? boolean | table | fun(): table
---@field module_name? string
M.PluginOpts = {}
M.PluginOpts.__index = M.PluginOpts

---@class Plugin
---@field name string
---@field _opts PluginOpts
M.Plugin = {}
M.Plugin.__index = M.Plugin

return M
