--- crust.nvim quickprompt: grey while idle, blue while the model works.
---
--- The state only moves when crust says so, so instead of letting heirline
--- cache the component between `User CrustQuickPrompt` events (which can
--- leave the icon blank in a window that has no cache yet), the component is
--- evaluated on every draw and the event simply forces a redraw.
local util = require("internal.ui.statusline.util")

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("internal.statusline.quickprompt", { clear = true }),
	pattern = "CrustQuickPrompt",
	desc = "Refresh the statusline quickprompt indicator",
	callback = util.redraw,
})

return {
	{
		init = function(self)
			local ok, quickprompt = pcall(require, "crust.quickprompt")
			self.status = ok and quickprompt.status() or { state = "idle" }
		end,
		provider = "󰚩",
		hl = function(self)
			if self.status.state == "running" then
				return { fg = colors.blue }
			end
			if self.status.state == "error" then
				return { fg = colors.red }
			end
			return { link = "Comment" }
		end,
	},
}
