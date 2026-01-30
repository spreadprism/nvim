local M = {}

---@class Lsp
---@field name string
---@field opts vim.lsp.Config
---@field cat? string
Lsp = {}
Lsp.__index = Lsp

---- Store all LSP configurations
---@type Lsp[]
local lsps = {}
local loaded = false

function M.load_lsp()
	for _, lsp in ipairs(lsps) do
		lsp:configure()
	end
	loaded = true
end

---@param name string
function M.lsp(name)
	if loaded then
		error("LSPs have already been loaded; cannot add new LSP: " .. name)
	end
	local lsp = setmetatable({ name = name, opts = {} }, Lsp)
	table.insert(lsps, lsp)
	return lsp
end

---@param cat string
---@return Lsp
function Lsp:for_cat(cat)
	self.cat = cat
	return self
end

function Lsp:configure()
	vim.lsp.config(self.name, self.opts)
	local opts = vim.lsp.config[self.name]
	if opts.cmd == nil then
		opts.cmd = { self.name }
		vim.lsp.config(self.name, opts)
	end
	vim.lsp.enable(self.name, true)
end

---@param cmd function | string[]
---@return Lsp
function Lsp:cmd(cmd)
	self.opts.cmd = cmd
	return self
end

---@param ... string
---@return Lsp
function Lsp:ft(...)
	self.opts.filetypes = { ... }
	return self
end

---@param ... string | table
---@return Lsp
function Lsp:root_markers(...)
	self.opts.root_markers = { ... }
	return self
end

---@param settings table
---@return Lsp
function Lsp:settings(settings)
	self.opts.settings = settings
	return self
end

---@param opts table
---@return Lsp
function Lsp:init_options(opts)
	self.opts.init_options = opts
	return self
end

return M
