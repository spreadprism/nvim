local lsp_utils = require("internal.lsp.utils")
---@class Lsp
---@field lsp_name string
---@field mason_name string
---@field setup_cond boolean | function
---@field display_var string | function TODO: Add code to cover if dispaly var is string
---@field auto_install_cond boolean | function
---@field opts table
---@field register_func function
local Lsp = {}
Lsp.__index = Lsp

---@param lsp_name string
---@param mason_name string | nil
function Lsp.new(lsp_name, mason_name)
	local self = setmetatable({}, Lsp)
	self.lsp_name = lsp_name
	self.mason_name = mason_name or lsp_name
	self.setup_cond = function()
		return true
	end
	self.display_var = function()
		return self.lsp_name
	end
	self.auto_install_cond = true
	self.opts = {} ---@type table
	self.opts.capabilities = lsp_utils.default_capabilities(self.lsp_name)
	self.register_func = nil
	-- self.opts.handlers = default_capabilities
	self.opts.on_attach = lsp_utils.default_on_attach
	lsp_utils.insert(self)
	return self
end

---@param cond fun(): boolean
function Lsp:cond(cond)
	self.setup_cond = cond
	return self
end

---@param display nil | fun(): string
function Lsp:display(display)
	self.display_var = display
	return self
end

function Lsp:capabilities(capabilities)
	self.opts.capabilities = vim.tbl_deep_extend("force", self.opts.capabilities, capabilities)
	return self
end

function Lsp:on_attach(on_attach)
	local temp = self.opts.on_attach or default_on_attach
	self.opts.on_attach = function(client, bufnr)
		temp(client, bufnr)
		on_attach(client, bufnr)
	end
	return self
end

function Lsp:filetypes(filetypes)
	self.opts.filetypes = vim.list_extend(self.opts.filetypes or {}, filetypes)
	return self
end

function Lsp:settings(settings)
	self.opts.settings = settings
	return self
end

---@param cmd string | table
function Lsp:cmd(cmd)
	if type(cmd) == "string" then
		cmd = { cmd }
	end
	self.opts.cmd = cmd
	return self
end

function Lsp:root_dir(root_dir)
	self.opts.root_dir = root_dir
	return self
end

function Lsp:auto_install(auto_install)
	self.auto_install_cond = auto_install
	return self
end

---@param register fun()
function Lsp:register(register)
	self.register_func = register
end

return Lsp.new
