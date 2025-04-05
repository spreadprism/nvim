local component = require("lualine.component"):extend()
local highlight = require("lualine.highlight")

local default_options = {
	max_object = 3,
	icons = {
		separator = "",
	},
	ft_blacklist = {
		"",
	},
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("pretty_path", {}),
		callback = function(args) end,
	})
end

function component:update_status() end

return component
