local M = {}

---@class Lsp
---@field name string
---@field opts vim.lsp.Config
---@field cat? string
Lsp = {}
Lsp.__index = Lsp

---@param name string
function M.lsp(name)
	local lsp = setmetatable({ name = name, opts = {} }, Lsp)
	vim.defer_fn(function()
		lsp:configure()
	end, 100)
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

---@param ... string
---@return Lsp
function Lsp:cmd(...)
	self.opts.cmd = { ... }
	return self
end

---@param ... string
---@return Lsp
function Lsp:ft(...)
	self.opts.filetypes = { ... }
	return self
end

---@param ... string
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
