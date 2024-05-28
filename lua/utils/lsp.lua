local default_capabilities = vim.lsp.protocol.make_client_capabilities()
local default_on_attach = function(client, bufnr) end
local M = {}
local all_lsp = {}
local Lsp = {}
Lsp.__index = Lsp

---@param lsp_name string
---@param mason_name string | nil
function Lsp.new(lsp_name, mason_name)
	local self = setmetatable({}, Lsp)
	self.lsp_name = lsp_name ---@type string
	self.mason_name = mason_name or lsp_name ---@type string
	self.setup_cond = function()
		return true
	end
	self.display_var = function()
		return self.lsp_name
	end
	self.auto_install_cond = true
	self.opts = {} ---@type table
	self.opts.capabilities = default_capabilities
	self.register_func = nil
	-- self.opts.handlers = default_capabilities
	self.opts.on_attach = default_on_attach
	table.insert(all_lsp, self)
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

function Lsp:cmd(cmd)
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

local initialized_servers = {}
function Lsp:configure()
	local configure = function()
		if not initialized_servers[self.lsp_name] and self.setup_cond() then
			require("lspconfig")[self.lsp_name].setup(self.opts)
		end
	end
	local ok, _ = pcall(configure)
	if ok then
		initialized_servers[self.lsp_name] = true
	else
		vim.notify("Failed to setup " .. self.lsp_name, vim.log.levels.WARNING, { title = "LspConfig" })
	end
end

M.Lsp = Lsp.new

M.setup_all_lsp = function()
	for _, lsp in ipairs(all_lsp) do
		if lsp.setup_cond() then
			if lsp.register_func then
				lsp.register_func()
			end
			lsp:configure()
		end
	end
end

M.get_display = function(lsp_name)
	for _, lsp in ipairs(all_lsp) do
		if lsp.lsp_name == lsp_name and lsp.display_var ~= nil then
			return lsp.display_var()
		end
	end
	return nil
end

M.all_lsp_mason = function()
	local lsp_install = {}
	for _, lsp in ipairs(all_lsp) do
		if lsp.auto_install_cond then
			table.insert(lsp_install, lsp.mason_name)
		end
	end
	return lsp_install
end

return M
