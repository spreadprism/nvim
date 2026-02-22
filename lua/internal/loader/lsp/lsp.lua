---@type table<string, Lsp>
local lsp_definitions = {}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf
	end,
})

event.on_plugin("lspconfig", function()
	for _, lsp in pairs(lsp_definitions) do
		local opts = vim.tbl_deep_extend("force", vim.lsp.config[lsp.name] or {}, lsp.opts or {})
		opts.cmd = opts.cmd or { lsp.name }
		vim.lsp.config(lsp.name, opts)
		vim.lsp.enable(lsp.name, true)
	end
end)

---@class Lsp
---@field name string
---@field opts vim.lsp.Config
---@field display string | fun(client: vim.lsp.Client, buf: number): string
Lsp = {}
Lsp.__index = Lsp

---@param display string | fun(client: vim.lsp.Client, buf: number): string
---@return Lsp
function Lsp:display(display)
	self.display = display
	return self
end

---@param cmd function | string[]
---@return Lsp
function Lsp:cmd(cmd)
	self.opts.cmd = cmd
	return self
end

---@param filetypes string | string[]
---@return Lsp
function Lsp:filetypes(filetypes)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end

	self.opts.filetypes = filetypes
	return self
end

---@param root_markers string | table
---@return Lsp
function Lsp:root_markers(root_markers)
	if type(root_markers) == "string" then
		root_markers = { root_markers }
	end

	self.opts.root_markers = root_markers
	return self
end

---@param settings lsp.LSPObject
---@return Lsp
function Lsp:settings(settings)
	self.opts.settings = settings
	return self
end

---@param name string
---@return Lsp
return function(name)
	if lsp_definitions[name] then
		return lsp_definitions[name]
	end
	local lsp = setmetatable({ name = name, opts = {}, _enable = true }, Lsp)

	lsp_definitions[name] = lsp
	return lsp
end
