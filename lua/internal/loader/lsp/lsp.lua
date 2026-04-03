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
		local opts = vim.tbl_deep_extend("force", vim.lsp.config[lsp.name] or {}, lsp._opts or {})
		opts.cmd = opts.cmd or { lsp.name }
		vim.lsp.config(lsp.name, opts)
		vim.lsp.enable(lsp.name, true)
	end
end)

---@class Lsp
---@field name string
---@field _opts vim.lsp.Config
---@field display_fn false | string | fun(client: vim.lsp.Client, buf: number): string
Lsp = {}
Lsp.__index = Lsp

---@param display false | string | fun(client: vim.lsp.Client, buf: number): string
---@return Lsp
function Lsp:display(display)
	if display == false then
		require("internal.loader.lsp").display_blacklist(self.name)
	else
		self.display_fn = display
	end
	return self
end

---@param cmd function | string[]
---@return Lsp
function Lsp:cmd(cmd)
	self._opts.cmd = cmd
	return self
end

---@param filetypes string | string[]
---@return Lsp
function Lsp:filetypes(filetypes)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end

	self._opts.filetypes = filetypes
	return self
end

---@param root_markers string | table
---@return Lsp
function Lsp:root_markers(root_markers)
	if type(root_markers) == "string" then
		root_markers = { root_markers }
	end

	self._opts.root_markers = root_markers
	return self
end

---@param settings lsp.LSPObject
---@return Lsp
function Lsp:settings(settings)
	self._opts.settings = settings
	return self
end

function Lsp:init_options(opts)
	self._opts.init_options = opts
	return self
end

function Lsp:opts(opts)
	self._opts = opts
end

---@param name string
---@return Lsp
return function(name)
	if lsp_definitions[name] then
		return lsp_definitions[name]
	end
	local lsp = setmetatable({ name = name, _opts = {}, _enable = true }, Lsp)

	lsp_definitions[name] = lsp
	return lsp
end
