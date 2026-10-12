--- crust.nvim: one icon for the two background models. Grey while both are
--- idle, blue while either works, red when either failed last.
---
--- The state only moves when crust says so, so instead of letting heirline
--- cache the component between the `User Crust*` events (which can leave the
--- icon blank in a window that has no cache yet), the component is evaluated
--- on every draw and the events simply force a redraw.
local util = require("internal.ui.statusline.util")
local event = require("internal.events")

local group = vim.api.nvim_create_augroup("internal.statusline.crust", { clear = true })

--- Nothing is asked of crust before lze has loaded it: until then the icon
--- stays idle and `require("crust.*")` is never called.
local loaded = false

event.on_plugin("crust", function()
	loaded = true

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = { "CrustQuickPrompt", "CrustQuickComplete" },
		desc = "Refresh the statusline crust indicator",
		callback = util.redraw,
	})

	util.redraw()
end, group)

--- Live state of a crust module, idle when it is not loaded yet.
---@param name string
---@return string
local function status(name)
	if not loaded then
		return "idle"
	end
	local ok, module = pcall(require, "crust." .. name)
	if not ok then
		return "idle"
	end
	local state = module.status()
	return state and state.state or "idle"
end

return {
	{
		init = function(self)
			self.states = {
				status("quickprompt"),
				status("quickcomplete"),
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
