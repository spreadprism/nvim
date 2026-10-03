--- nvim-dap session indicator.
---
--- nvim-dap only exposes one autocmd, `User DapProgressUpdate` (fired from
--- `dap/progress.lua` on adapter start, session start/stop and other progress
--- reports). Everything else goes through `dap.listeners`:
---
---   * `dap.listeners.on_session(old, new)` -- active session changed
---   * `dap.listeners.after.<event|request>[key]` -- protocol traffic
---
--- The component is evaluated on every statusline draw; what was missing is
--- the *redraw* when the session state changes. The autocmd is what tells us
--- dap got loaded at all (it fires before the session exists), and from there
--- we register listeners for the events that change what we show.
local util = require("internal.ui.statusline.util")

local LISTENER = "internal.statusline.dap"

--- Events after which the session state may have changed.
local events = {
	"event_initialized",
	"event_stopped",
	"event_continued",
	"event_terminated",
	"event_exited",
	"attach",
	"launch",
	"disconnect",
	"terminate",
}

local symbol = ""

local attached = false

--- Register the dap listeners once dap is loaded. Safe to call repeatedly.
local function attach()
	if attached or not package.loaded.dap then
		return
	end
	attached = true

	local dap = require("dap")

	dap.listeners.on_session[LISTENER] = util.redraw

	for _, event in ipairs(events) do
		dap.listeners.after[event][LISTENER] = util.redraw
	end
end

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("internal.statusline.dap", { clear = true }),
	pattern = "DapProgressUpdate",
	desc = "Refresh the statusline dap indicator",
	callback = function()
		attach()
		util.redraw()
	end,
})

return {
	{
		init = function(self)
			self.session = package.loaded.dap and require("dap").session() or nil
		end,
		provider = function(self)
			if self.session then
				local name = self.session.config and self.session.config.name or ""
				return symbol .. " (" .. name .. ")"
			else
				return symbol
			end
		end,
		hl = function(self)
			if self.session then
				if self.session.initialized then
					return { fg = colors.green }
				else
					return { fg = colors.blue }
				end
			else
				return { fg = colors.comment }
			end
		end,
	},
}
