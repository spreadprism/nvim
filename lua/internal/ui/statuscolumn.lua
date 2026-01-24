local component = require("heirline-components.all").component

local statuscolumn = {
	init = function(self)
		self.bufnr = vim.api.nvim_get_current_buf()
	end,
	component.signcolumn(),
	component.foldcolumn(),
	component.fill(),
	component.numbercolumn(),
}

return statuscolumn
