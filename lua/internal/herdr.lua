-- Report neovim's cwd to the host terminal/multiplexer with OSC 7.
--
-- herdr (and kitty) derive a pane's working directory from the OSC 7 reports
-- the shell emits at each prompt. While neovim owns the pty nothing reports
-- anything, so `prefix+s`/`prefix+v`/new tabs (terminal.new_cwd = "follow")
-- keep opening in the directory the shell was in when neovim started.
-- Re-emitting on every :cd keeps them following neovim instead.

local M = {}

local group = vim.api.nvim_create_augroup("HerdrCwd", { clear = true })

-- NOTE: the authority stays empty (`file:///path`). herdr 0.9 only accepts an
-- empty host or `localhost` and silently ignores the report for anything else,
-- including this machine's own `hostname` (`macflow.local`).
---@return string
local function cwd_uri()
	return vim.uri_from_fname(vim.fn.getcwd(-1, -1))
end

--- Emit the current working directory as an OSC 7 sequence on nvim's stderr,
--- which is the terminal pty (writing to stdout is swallowed by the UI).
function M.report()
	vim.fn.chansend(vim.v.stderr, ("\027]7;%s\027\\"):format(cwd_uri()))
end

--- Hand the final cwd back to the shell that launched nvim.
---
--- A child process cannot chdir its parent, so the wrapper *function* around
--- nvim passes a scratch path in `$NVIM_CWD_FILE` and `cd`s to whatever we
--- leave in it once nvim exits.
function M.write_exit_cwd()
	local path = vim.env.NVIM_CWD_FILE
	if not path or path == "" then
		return
	end
	pcall(vim.fn.writefile, { vim.fn.getcwd(-1, -1) }, path)
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	group = group,
	desc = "report cwd to the terminal via OSC 7",
	callback = M.report,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	desc = "hand the cwd back to the parent shell",
	callback = M.write_exit_cwd,
})

return M
