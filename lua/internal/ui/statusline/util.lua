--- Small helpers shared by the event driven statusline components.
---
--- A heirline component is only re-evaluated when the statusline is redrawn,
--- and nothing redraws it when an external plugin changes state in the
--- background. Push based components (overseer, dap, crust) therefore need
--- two things: a way to force a redraw from an autocmd/listener, and a cheap
--- timer for time limited state (e.g. "flash green for 3s after success").
---
--- Note: no component here sets heirline's `update` field. Doing so opts the
--- component into heirline's per-window cache (`_win_cache`), which is what
--- made icons render blank; evaluating these tiny components on every draw is
--- cheap and always correct.
local M = {}

--- Force a statusline redraw, safe to call from a libuv callback.
function M.redraw()
	if vim.in_fast_event() then
		vim.schedule(M.redraw)
		return
	end
	pcall(vim.cmd.redrawstatus)
end

---@class statusline.Oneshot
---@field start fun(self: statusline.Oneshot, ms: integer, fn: fun()) (re)arm the timer
---@field cancel fun(self: statusline.Oneshot) cancel a pending run

--- Create a restartable one-shot timer.
---@return statusline.Oneshot
function M.oneshot()
	local timer = nil

	---@type statusline.Oneshot
	---@diagnostic disable-next-line: missing-fields
	local handle = {}

	function handle:cancel()
		if timer and not timer:is_closing() then
			timer:stop()
			timer:close()
		end
		timer = nil
	end

	function handle:start(ms, fn)
		self:cancel()
		timer = vim.defer_fn(function()
			timer = nil
			fn()
		end, ms)
	end

	return handle
end

return M
