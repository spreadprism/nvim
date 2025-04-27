local component = require("lualine.component"):extend()

local default_options = {
	blacklist = {},
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})
end

local function get_venv()
	local venv = ""
	if not internal.plugin_loaded("venv-selector") then
		return venv
	end
	local vs = require("venv-selector")
	local source = vs.source()
	if source == "workspace" then
		venv = "venv"
	else
		venv = vs.venv()
		if venv == nil then
			return ""
		end
		local dirname = vim.fn.fnamemodify(venv, ":t")
		if dirname == ".venv" then
			dirname = "venv"
		end
		venv = dirname
	end
	return "(" .. venv .. ")"
end

function component:update_status()
	local clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
	clients = vim.tbl_filter(function(c)
		return not vim.tbl_contains(self.options.blacklist, c.name)
	end, clients)

	clients = vim.tbl_map(function(c)
		if c.name == "basedpyright" then
			return c.name .. get_venv()
		end
		return c.name
	end, clients)

	return table.concat(clients, ", ")
end

return component
