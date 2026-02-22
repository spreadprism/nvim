local ERROR = vim.diagnostic.severity.ERROR
local WARN = vim.diagnostic.severity.WARN
local INFO = vim.diagnostic.severity.INFO
return {
	static = {
		workspace_diagnostics = function(severity)
			local count = vim.diagnostic.get(nil, { severity = severity })
			return vim.tbl_count(count) or 0
		end,
	},
	init = function(self)
		self.count = {
			[ERROR] = self.workspace_diagnostics(ERROR),
			[WARN] = self.workspace_diagnostics(WARN),
			[INFO] = self.workspace_diagnostics(INFO),
		}
	end,
	{
		provider = function(self)
			return symbols.error .. " " .. self.count[ERROR] .. " "
		end,
		hl = { fg = colors.error },
	},
	{
		provider = function(self)
			return symbols.warning .. " " .. self.count[WARN] .. " "
		end,
		hl = { fg = colors.warning },
	},
	{
		provider = function(self)
			return symbols.info .. " " .. self.count[INFO] .. " "
		end,
		hl = { fg = colors.info },
	},
}
