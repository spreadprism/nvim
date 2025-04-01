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

---@param display boolean
function LspPlugin:display(display)
	M.set_client_display(self.name, display)
end

---@type table<string, boolean>
local client_filter = {}
---@param bufnr number
function M.get_clients(bufnr)
	local all_clients = vim.lsp.get_clients({ bufnr = bufnr }) or {}
	all_clients = vim.tbl_map(function(val)
		return val.name
	end, all_clients)
	return vim.tbl_filter(function(val)
		return client_filter[val] or client_filter[val] == nil
	end, all_clients)
end
---@param client string
---@param display boolean
function M.set_client_display(client, display)
	client_filter[client] = display
end
return M
