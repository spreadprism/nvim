local component = require("heirline-components.all").component

local statuscolumn = {
	init = function(self)
		self.bufnr = vim.api.nvim_get_current_buf()
	end,
	component.foldcolumn(),
	component.fill(),
	component.numbercolumn(),
	component.signcolumn(),
}

return statuscolumn
