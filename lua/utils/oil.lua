local M = {}

local HOME = os.getenv("HOME")

M.winbar = function()
	local ok, oil = pcall(require, "oil")
	local dir = nil
	if ok then
		dir = oil.get_current_dir()
		if dir ~= nil then
			local cwd = vim.fn.getcwd()
			local cwd_dir_name = vim.fn.fnamemodify(cwd, ":t")
			dir = dir:gsub(cwd, "/" .. cwd_dir_name)
			-- dir = string.gsub(dir, cwd, "/" .. cwd_dir_name)
			---@diagnostic disable-next-line: param-type-mismatch
			dir = dir:gsub(HOME, "~")
			-- remove trailing slash
			dir = dir:gsub("/$", "")
			-- remove leading slash
			dir = dir:gsub("^/", "")
			-- replace slash by arrow
			dir = dir:gsub("/", "  ")
		end
	end
	return dir or ""
end
return M
