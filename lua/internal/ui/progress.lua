--- Ad-hoc progress spinners rendered exactly like LSP init progress: the
--- message is injected into noice's pipeline as an `lsp`/`progress` event, so
--- it follows the same route (mini view, bottom right) and formats
--- (`lsp.progress.format` / `format_done`) as real `$/progress` messages.
---
--- ```lua
--- local progress = require("internal.ui.progress").start({
---   client = "direnv",
---   title = "export",
---   message = "~/workspace/foo",
--- })
--- -- later
--- progress:finish({ message = "done" })
--- ```
---
--- When noice is not loaded (yet), falls back to a single `vim.notify`.
local M = {}

---@class internal.Progress
---@field private n? { config: table, format: table, manager: table, message: table }
---@field private message? table noice message carrying `opts.progress`
---@field private timer? uv.uv_timer_t
---@field private done boolean
local Handle = {}
Handle.__index = Handle

--- The noice internals the spinner needs, or nil when noice is not ready.
local function noice_mods()
	if not package.loaded["noice"] then
		return nil
	end
	local ok, mods = pcall(function()
		return {
			config = require("noice.config"),
			format = require("noice.text.format"),
			manager = require("noice.message.manager"),
			message = require("noice.message"),
		}
	end)
	if not ok or not vim.tbl_get(mods.config, "options", "lsp", "progress") then
		return nil
	end
	return mods
end

---@class internal.ProgressOpts
---@field client? string shown like the LSP client name (default "progress")
---@field title string
---@field message? string

--- Start a spinner. Always returns a handle; call `:finish()` when done.
---@param opts internal.ProgressOpts
---@return internal.Progress
function M.start(opts)
	local self = setmetatable({ done = false }, Handle)

	local n = noice_mods()
	if not n then
		vim.notify(
			string.format("%s: %s…", opts.title, opts.message or ""),
			vim.log.levels.INFO,
			{ title = opts.client or "progress" }
		)
		return self
	end

	self.n = n
	self.message = n.message("lsp", "progress")
	self.message.opts.progress = {
		client_id = "internal/" .. (opts.client or "progress"),
		client = opts.client or "progress",
		kind = "begin",
		title = opts.title,
		message = opts.message,
	}

	-- noice re-formats progress messages on an interval to animate the
	-- spinner ({spinner} derives its frame from the clock); do the same
	self.timer = vim.uv.new_timer()
	self.timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			if not self.done then
				n.manager.add(n.format.format(self.message, n.config.options.lsp.progress.format))
			end
		end)
	)

	return self
end

--- Stop the spinner, briefly showing the done format (like LSP progress end).
---@param opts? { message?: string }
function Handle:finish(opts)
	if self.done then
		return
	end
	self.done = true

	if self.timer then
		self.timer:stop()
		if not self.timer:is_closing() then
			self.timer:close()
		end
		self.timer = nil
	end

	local n = self.n
	if not n then
		return
	end

	vim.schedule(function()
		local progress = self.message.opts.progress
		progress.kind = "end"
		if opts and opts.message then
			progress.message = opts.message
		end
		n.manager.add(n.format.format(self.message, n.config.options.lsp.progress.format_done))
		-- same grace period noice gives its own progress before removal;
		-- the mini view keeps the done line visible until its own timeout
		vim.defer_fn(function()
			n.manager.remove(self.message)
		end, 100)
	end)
end

return M
