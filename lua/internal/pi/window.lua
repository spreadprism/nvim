local ft = require("internal.pi.ft")

local M = {}

--- PI exposes no option for this, and there's no buffer/window option in
--- Neovim that makes a window "not count" for the last-window check, so we
--- hide the chat ourselves on `QuitPre`: when the window being quit is the
--- last non-PI window, closing the PI panels lets Neovim exit as usual.
function M.close_when_last()
	vim.api.nvim_create_autocmd("QuitPre", {
		group = vim.api.nvim_create_augroup("PiCloseWhenLast", { clear = true }),
		callback = function()
			local current = vim.api.nvim_get_current_win()

			-- quitting a PI window itself: nothing to do
			if vim.tbl_contains(ft.panels, vim.bo.filetype) then
				return
			end

			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				local floating = vim.api.nvim_win_get_config(win).relative ~= ""

				if win ~= current and not floating and not vim.tbl_contains(ft.panels, vim.bo[buf].filetype) then
					return
				end
			end

			local ok, pi = pcall(require, "pi")
			if ok and pi.is_visible() then
				pi.toggle_chat()
			end
		end,
	})
end

return M
