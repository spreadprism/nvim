local M = {}

local buffer_blacklist = {
	"neo-tree filesystem [1]",
	"[dap-repl]",
	"DAP Console",
	"DAP Watches",
	"NeogitStatus",
	"NeogitDiffView",
	"null",
	"DiffviewFilePanel",
}
local buffer_extension_blacklist = { "harpoon" }
local buffer_mode_blacklist = { "t" }

---@param cmd string
M.cmd_on_click = function(cmd)
	return function(_, mouse_button, _)
		if mouse_button == "l" then
			vim.cmd(cmd)
		end
	end
end

M.display_file = function()
	local current_buffer_mode = vim.api.nvim_get_mode().mode
	local current_buffer_name = vim.fn.expand("%:t")
	local current_buffer_filetype = vim.bo.filetype

	-- INFO: Check if current buffer mode is in the blacklist
	for _, mode in ipairs(buffer_mode_blacklist) do
		if current_buffer_mode == mode then
			return false
		end
	end

	-- INFO: Don't need to check if buffer_name is empty
	if current_buffer_name == "" then
		return false
	end

	-- INFO: Check if current buffer name is in the blacklist
	for _, buffer_name in ipairs(buffer_blacklist) do
		if current_buffer_name == buffer_name then
			return false
		end
	end

	-- INFO: Check if current buffer extension is in the blacklist
	for _, buffer_extension in ipairs(buffer_extension_blacklist) do
		if current_buffer_filetype == buffer_extension then
			return false
		end
	end

	return true
end

return M
