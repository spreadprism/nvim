local component = require("lualine.component"):extend()

local default_options = {
	blacklist = {},
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})
end

function component:update_status()
	local clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
	clients = vim.tbl_map(function(c)
		return c.name
	end, clients)

	clients = vim.tbl_filter(function(c)
		return not vim.tbl_contains(self.options.blacklist, c)
	end, clients)

	return table.concat(clients, ", ")
end

return component
