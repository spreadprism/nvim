local M = {}
local winbar_cond = require("internal.winbar").winbar_cond

local function get_path()
	local cwd = cwd()
	local path = ""
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			---@diagnostic disable-next-line: cast-local-type
			path = oil.get_current_dir()
		else
			return ""
		end
	else
		-- cwd = string.gsub(cwd, "[^/]*$", "")
		path = vim.fn.expand("%:p")
	end

	-- remove trailing /
	---@diagnostic disable-next-line: param-type-mismatch
	path = string.gsub(path, "/$", "")
	path = string.gsub(path, cwd, vim.fn.fnamemodify(cwd, ":t"))
	-- remove leading /
	path = string.gsub(path, "^/", "")

	-- path = joinpath(, path)
	return path
end

function M.lead_path()
	local path = get_path()
	---@diagnostic disable-next-line: cast-local-type
	path = vim.split(path, "/", { trimempty = true })
	local len = #path
	if #path == 0 then
		return ""
	end
	table.remove(path, #path)
	if #path >= 4 then
		---@diagnostic disable-next-line: cast-local-type
		path = { path[1], "...", path[#path - 1], path[#path] }
	end
	-- join table
	path = table.concat(path, "  ")
	if len > 1 then
		path = path .. " "
	end
	return path
end

function M.oil_filename()
	local path = get_path()
	---@diagnostic disable-next-line: cast-local-type
	path = vim.split(path, "/", { trimempty = true })
	return path[#path]
end

M.component = {
	{
		M.lead_path,
		color = { fg = "#737aa2", bg = "NONE" },
		padding = { left = 1, right = 0 },
		cond = winbar_cond(),
	},
	{
		"filetype",
		icon_only = true,
		separator = "",
		padding = { left = 1, right = 0 },
		cond = winbar_cond(function()
			return vim.bo.filetype ~= "oil"
		end),
		color = { bg = "OilFile" },
	},
	{
		"filename",
		path = 0,
		separator = "",
		padding = { left = 0, right = 1 },
		symbols = { modified = Symbols.modified, readonly = Symbols.readonly, unnamed = "" },
		color = { fg = "#c0caf5", bg = "None" },
		cond = winbar_cond(function()
			return vim.bo.filetype ~= "oil"
		end),
	},
	{
		function()
			local path = get_path()
			---@diagnostic disable-next-line: cast-local-type
			path = vim.split(path, "/", { trimempty = true })
			return path[#path]
		end,
		padding = { left = 1, right = 1 },
		color = "OilFile",
		cond = winbar_cond(function()
			return vim.bo.filetype == "oil"
		end),
	},
}

return M
