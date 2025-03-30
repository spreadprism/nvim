local function get_path()
	local cwd = cwd()
	local path = ""
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			path = oil.get_current_dir()
		else
			return ""
		end
	else
		-- cwd = string.gsub(cwd, "[^/]*$", "")
		path = vim.fn.expand("%:p")
	end

	path = string.gsub(path, cwd, vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
	-- remove trailing /
	path = string.gsub(path, "/$", "")
	-- remove leading /
	path = string.gsub(path, "^/", "")

	-- path = joinpath(, path)
	return path
end
return {
	{
		function()
			local path = get_path()
			path = vim.split(path, "/", { trimempty = true })
			local len = #path
			if #path == 0 then
				return ""
			end
			table.remove(path, #path)
			if #path >= 4 then
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
	},
	{
		"filetype",
		icon_only = true,
		separator = "",
		padding = { left = 1, right = 0 },
		cond = function()
			return vim.bo.filetype ~= "oil"
		end,
		color = { bg = "OilFile" },
	},
	{
		"filename",
		path = 0,
		separator = "",
		padding = { left = 0, right = 1 },
		symbols = { modified = Symbols.modified, readonly = Symbols.readonly, unnamed = "" },
		color = "OilFile",
		cond = function()
			return vim.bo.filetype ~= "oil"
		end,
	},
	{
		function()
			local path = get_path()
			path = vim.split(path, "/", { trimempty = true })
			return path[#path]
		end,
		padding = { left = 1, right = 1 },
		color = "OilFile",
		cond = function()
			return vim.bo.filetype == "oil"
		end,
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
		cond = function()
			local ok, _ = pcall(require, "harpoon")
			return ok
		end,
		separator = "",
		padding = { left = 0, right = 1 },
	},
}
