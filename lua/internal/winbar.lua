local M = {}

local ft_blacklist = {
	"trouble",
	"NeogitStatus",
	"dap-repl",
	"dapui_scopes",
	"dapui_watches",
	"dapui_stacks",
	"dapui_console",
}

function M.winbar_cond(cond)
	if cond == nil then
		cond = function()
			return true
		end
	end
	local f = function()
		if vim.tbl_contains(ft_blacklist, vim.bo.filetype) then
			return false
		end
		return true
	end
	return function()
		return f() and cond()
	end
end

return M
