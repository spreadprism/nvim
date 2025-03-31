return {
	{
		function()
			return require("dap").status()
		end,
		icon = { "", color = { fg = "#e7c664" } }, -- nerd icon.
		cond = function()
			if not package.loaded.dap then
				return false
			end
			local session = require("dap").session()
			return session ~= nil
		end,
	},
}
