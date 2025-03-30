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

	---@diagnostic disable-next-line: param-type-mismatch
	path = string.gsub(path, cwd, vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
	-- remove trailing /
	path = string.gsub(path, "/$", "")
	-- remove leading /
	path = string.gsub(path, "^/", "")

	-- path = joinpath(, path)
	return path
end

local ft_blacklist = {
	"trouble",
	"NeogitStatus",
}

---@param cond? fun(): boolean
local function winbar_cond(cond)
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

return {
	{
		function()
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
		end,
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
		color = "OilFile",
		cond = winbar_cond(function()
			return vim.bo.filetype ~= "oil"
		end),
	},
	{
		function()
			local path = get_path()
			path = vim.split(path, "/", { trimempty = true })
			return path[#path]
		end,
		padding = { left = 1, right = 1 },
		color = "OilFile",
		cond = winbar_cond(function()
			return vim.bo.filetype == "oil"
		end),
	},
	{
		function()
			local ok, harpoon = pcall(require, "harpoon")

			if not ok then
				return ""
			end

			local marks = harpoon:list().items
			local current_buffer = vim.fn.expand("%s"):gsub(vim.fn.getcwd() .. "/", "")

			for _, mark in ipairs(marks) do
				if current_buffer == mark.value then
					return ""
				end
			end
			return ""
		end,
		color = { fg = Colors.red, bg = "none" },
		cond = winbar_cond(function()
			local ok, _ = pcall(require, "harpoon")
			return ok
		end),
		separator = "",
		padding = { left = 0, right = 1 },
	},
}
