local M = {}

function M.cargo(config)
	local final_config = vim.deepcopy(config)
	local project_name = vim.fn.fnamemodify(cwd(), ":t")
	vim.cmd("OverseerRunCmd cargo build --bin=" .. project_name)
end

return M
