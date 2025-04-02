return {
	function()
		local ok, dap = pcall(require, "dap")
		if not ok then
			return " "
		end
		local session = dap.session()
		if session == nil then
			return " "
		end
		return session.config.name
	end,
	separator = "",
	icon = {
		"",
		color = function()
			local ok, dap = pcall(require, "dap")
			if not ok then
				return ""
			end
			local session = dap.session()
			if session == nil then
				return { fg = "#565f89" }
			end
			if not session.initialized then
				return { fg = Colors.yellow }
			end
			return { fg = Colors.blue }
		end,
	},
}
