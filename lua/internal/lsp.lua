local M = {}
local lze = require("internal.plugin.lze")
vim.g.lsp_display = {}

---@class Lsp
---@field name string
Lsp = {}
Lsp.__index = Lsp

---@param name string
---@return Lsp
function M.lsp(name)
	local lsp = setmetatable({
		name = name,
		lsp = {},
	}, Lsp)

	lze.apply(name, lsp)
	return lsp
end

---@param ... string
---@return Lsp
function Lsp:ft(...)
	lze.apply(self.name, { lsp = { filetypes = { ... } } })
	return self
end

---@param ... string
---@return Lsp
function Lsp:cmd(...)
	lze.apply(self.name, { lsp = { filetypes = { ... } } })
	return self
end

---@param ... string
---@return Lsp
function Lsp:root_dir(...)
	local args = ...
	lze.apply(self.name, {
		lsp = {
			root_dir = {
				function(startpath)
					return require("lspconfig.util").root_pattern(args)(startpath) or cwd()
				end,
			},
		},
	})
	return self
end

---@param settings table
---@return Lsp
function Lsp:settings(settings)
	lze.apply(self.name, { lsp = { settings = settings } })
	return self
end

---@param enabled boolean
---@return Lsp
function Lsp:enabled(enabled)
	lze.apply(self.name, { enabled = enabled })
	return self
end

---@param display boolean
---@return Lsp
function Lsp:display(display)
	M.set_client_display(self.name, display)
	return self
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
