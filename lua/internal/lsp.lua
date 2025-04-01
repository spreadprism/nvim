local M = {}
local specs = require("internal.specs")
vim.g.lsp_display = {}

---@class LspPlugin: Plugin
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

function LspPlugin:enabled(enabled)
	specs.apply(self.name, { enabled = enabled })
	return self
end

---@param lsp_name string
---@param config table
---@param force? boolean
function LspPlugin:config(lsp_name, config, force)
	local configs = require("lspconfig/configs")
	if force or not configs[lsp_name] then
		configs[lsp_name] = {
			default_config = config,
		}
	end
	return self
end

function LspPlugin:setup(lsp_name, opts)
	require("lspconfig")[lsp_name].setup(opts)
	return self
end

return M
