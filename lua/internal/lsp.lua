local M = {}
local specs = require("internal.specs")

---@class LspPlugin
---@field name string
LspPlugin = {}
LspPlugin.__index = LspPlugin

---@param name string
---@return LspPlugin
function M.lsp(name)
	return specs.init(name, { lsp = {} }, LspPlugin)
end

---@param ft string | string[]
---@return LspPlugin
function LspPlugin:ft(ft)
	specs.apply(self.name, { lsp = { filetypes = ft } })
	return self
end

---@param settings table
---@return LspPlugin
function LspPlugin:settings(settings)
	specs.apply(self.name, { lsp = { settings = settings } })
	return self
end

return M
