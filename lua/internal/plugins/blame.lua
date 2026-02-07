vim.g.line_blame = false
vim.g.buffer_blame = false

local M = {}

function M.line_blame()
	if vim.g.buffer_blame then
		M.buffer_blame()
	end

	require("gitsigns").toggle_current_line_blame()
	vim.g.line_blame = not vim.g.line_blame
end

function M.buffer_blame()
	if vim.g.line_blame then
		M.line_blame()
	end
	vim.cmd("BlameToggle virtual")
	vim.g.buffer_blame = not vim.g.buffer_blame
end

return M
