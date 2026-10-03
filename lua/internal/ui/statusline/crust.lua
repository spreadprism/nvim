--- crust.nvim: one icon for the two background models. Grey while both are
--- idle, blue while either works, red when either failed last.
---
--- The state only moves when crust says so, so instead of letting heirline
--- cache the component between the `User Crust*` events (which can leave the
--- icon blank in a window that has no cache yet), the component is evaluated
--- on every draw and the events simply force a redraw.
local util = require("internal.ui.statusline.util")

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("internal.statusline.crust", { clear = true }),
	pattern = { "CrustQuickPrompt", "CrustQuickComplete" },
	desc = "Refresh the statusline crust indicator",
	callback = util.redraw,
})

--- Live state of a crust module, idle when it is not loaded yet.
---@param name string
---@return { state: string }
local function status(name)
	local ok, module = pcall(require, "crust." .. name)
	return ok and module.status() or { state = "idle" }
end

return {
	{
		init = function(self)
			self.states = {
				status("quickprompt").state,
				status("quickcomplete").state,
			}
		end,
		provider = "󰚩",
		hl = function(self)
			-- Working beats failed: what is happening now is the news.
			if vim.tbl_contains(self.states, "running") then
				return { fg = colors.blue }
			end
			if vim.tbl_contains(self.states, "error") then
				return { fg = colors.red }
			end
			return { link = "Comment" }
		end,
	},
}
