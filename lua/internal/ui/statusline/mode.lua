return {
	init = function(self)
		self.mode = vim.fn.mode(1)
	end,
	static = {
		mode_names = {
			["n"] = "NORMAL",
			["no"] = "O-PENDING",
			["nov"] = "O-PENDING",
			["noV"] = "O-PENDING",
			["no\22"] = "O-PENDING",
			["niI"] = "NORMAL",
			["niR"] = "NORMAL",
			["niV"] = "NORMAL",
			["nt"] = "NORMAL",
			["ntT"] = "NORMAL",
			["v"] = "VISUAL",
			["vs"] = "VISUAL",
			["V"] = "V-LINE",
			["Vs"] = "V-LINE",
			["\22"] = "V-BLOCK",
			["\22s"] = "V-BLOCK",
			["s"] = "SELECT",
			["S"] = "S-LINE",
			["\19"] = "S-BLOCK",
			["i"] = "INSERT",
			["ic"] = "INSERT",
			["ix"] = "INSERT",
			["R"] = "REPLACE",
			["Rc"] = "REPLACE",
			["Rx"] = "REPLACE",
			["Rv"] = "V-REPLACE",
			["Rvc"] = "V-REPLACE",
			["Rvx"] = "V-REPLACE",
			["c"] = "COMMAND",
			["cv"] = "EX",
			["ce"] = "EX",
			["r"] = "REPLACE",
			["rm"] = "MORE",
			["r?"] = "CONFIRM",
			["!"] = "SHELL",
			["t"] = "TERMINAL",
		},
	},
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd.redrawstatus()
		end),
	},
	{
		provider = function(self)
			return " " .. self.mode_names[self.mode] .. " "
		end,
		hl = function(self)
			return { fg = colors.black, bg = self.mode_color(), bold = true }
		end,
	},
	{
		provider = function(_)
			return Symbols.separators.angle.left
		end,
		hl = function(self)
			return { fg = self.mode_color(), bold = true }
		end,
	},
}
