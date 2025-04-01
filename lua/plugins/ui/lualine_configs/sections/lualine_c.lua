return {
	{
		function()
			local ok, dap = pcall(require, "dap")
			if not ok then
				return " "
			end
			local session = dap.session()
			if session == nil then
				return " "
			end

			return string.lower(dap.status())
		end,
		draw_empty = true,
		icon = {
			"",
			color = function()
				local ok, dap = pcall(require, "dap")
				if not ok then
					return ""
				end
				---@type dap.Session
				local session = dap.session()
				if session == nil then
					return { fg = "#565f89" }
				end
				if not session.initialized then
					return { fg = "#e7c664" }
				end
				return { fg = "#1abc9c" }
			end,
		}, -- nerd icon.
	},
}
