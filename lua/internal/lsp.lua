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
	return lsp:cmd(name)
end

---@param cat string
---@return Lsp
function Lsp:for_cat(cat)
	self.cat = cat
	return self
end
function Lsp:configure()
	vim.lsp.config[self.name] = vim.tbl_deep_extend("force", vim.lsp.config[self.name] or {}, self.opts)

	local final_cfg = vim.lsp.config[self.name]
	local cat = nixCats(self.cat or "core")
	local executable = vim.fn.executable(final_cfg.cmd[1]) == 1
	if cat and not executable then
		-- notify warn that we should enable but executable is missing
		vim.notify(self.name .. " missing executable " .. final_cfg.cmd[1], vim.log.levels.WARN, { title = "LSP" })
	end

	vim.lsp.enable(self.name, cat and executable)
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

---@param ... string
---@return Lsp
function Lsp:settings(...)
	self.opts.settings = { ... }
	return self
end

return M
