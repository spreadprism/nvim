local M = {}

local dependencies_available = vim.fn.executable("figlet") and vim.fn.executable("lolcat")

M.can_generate_header = dependencies_available
M.get_dir = function()
	return vim.fs.joinpath(vim.fn.stdpath("data"), "dashboard")
end
---@param id string
M.get_path = function(id)
	return vim.fs.joinpath(M.get_dir(), id)
end
M.refresh_header = function(header_txt, width, id)
	if dependencies_available then
		local path = M.get_path(id)
		if not vim.fn.exists(M.get_dir()) then
			vim.cmd("silent !mkdir " .. M.get_dir())
		end
		vim.cmd("silent !rm -f " .. path)
		local header_cmd = "figlet -c -w " .. width .. " -f 'ANSI Shadow' " .. header_txt .. " > " .. path
		vim.cmd("silent !" .. header_cmd)
	else
		vim.notify("dependencies not available")
	end
end

return M
