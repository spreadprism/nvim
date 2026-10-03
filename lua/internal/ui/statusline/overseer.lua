--- Overseer task indicator.
---
--- Overseer pushes a single autocmd whenever its task list changes:
---
---   :au User OverseerListUpdate
---
--- `overseer/task_list/init.lua` fires it from `dispatch()`, which is reached
--- from `touch()` (task created), `on_task_updated()` (bound to every task's
--- `on_status` event in `overseer/task.lua`) and `remove()` (task disposed).
--- So every transition we care about -- PENDING -> RUNNING ->
--- SUCCESS/FAILURE/CANCELED -> disposed -- lands there.
---
--- The component itself is evaluated on every statusline draw (no `update`
--- field, so no heirline caching); what was missing is the *redraw*. This
--- module listens to the overseer event and forces one, and remembers the
--- last result because tasks are usually disposed right after they finish,
--- which used to make the success/failure colour disappear instantly.
local util = require("internal.ui.statusline.util")

--- How long a finished task keeps colouring the icon.
local RESULT_TIMEOUT_MS = 3000

--- Statuses that are a final result worth flashing in the statusline.
local results = {
	SUCCESS = true,
	FAILURE = true,
	CANCELED = true,
}

---@class statusline.OverseerState
---@field running boolean a task is currently running
---@field recent? { status: string, at: integer } last finished task
local state = {
	running = false,
	recent = nil,
}

--- Last status seen per task id, used to detect transitions.
---@type table<integer, string>
local seen = {}

--- Fades the result colour back to idle once the timeout elapses.
local expire = util.oneshot()

local function refresh()
	if not package.loaded.overseer then
		return
	end

	---@type overseer.Task[]
	local tasks = require("overseer").list_tasks({ include_ephemeral = true })

	local running = false
	local alive = {}

	for _, task in ipairs(tasks) do
		alive[task.id] = true
		running = running or task.status == "RUNNING"

		if seen[task.id] ~= task.status and results[task.status] then
			state.recent = { status = task.status, at = vim.uv.now() }
			expire:start(RESULT_TIMEOUT_MS, util.redraw)
		end

		seen[task.id] = task.status
	end

	for id in pairs(seen) do
		if not alive[id] then
			seen[id] = nil
		end
	end

	state.running = running
	util.redraw()
end

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("internal.statusline.overseer", { clear = true }),
	pattern = "OverseerListUpdate",
	desc = "Refresh the statusline overseer indicator",
	callback = refresh,
})

return {
	{
		init = function(self)
			if state.running then
				self.status = "RUNNING"
			elseif state.recent and vim.uv.now() - state.recent.at < RESULT_TIMEOUT_MS then
				self.status = state.recent.status
			else
				self.status = nil
			end
		end,
		provider = "󱁤",
		hl = function(self)
			if self.status == "RUNNING" then
				return { fg = colors.orange }
			elseif self.status == "SUCCESS" then
				return { fg = colors.green }
			elseif self.status == "FAILURE" then
				return { fg = colors.red }
			end
			return { link = "Comment" }
		end,
	},
}
