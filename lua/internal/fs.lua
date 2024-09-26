local M = {}

local function expand_home(path)
	local home = os.getenv("HOME")
	if not home then
		return path
	end

	return path:match("^~") and (home .. path:sub(2)) or path
end

---@param dir string
---@param depth integer | string
---@param ext string
M.list_files = function(dir, depth, ext)
	if depth == nil then
		depth = 1
	end
	ext = ext or "*"

	if depth ~= "*" and depth <= 0 then
		return
	end

	dir = expand_home(dir)

	local files = {}

	local handle = vim.loop.fs_scandir(dir)
	if not handle then
		return
	end

	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		if type == "file" then
			table.insert(files, name)
		elseif (depth == "*" or depth > 1) and type == "directory" then
			local new_depth = depth
			if depth ~= "*" then
				new_depth = depth - 1
			end
			for _, file in ipairs(M.list_files(vim.fs.joinpath(dir, name), new_depth, ext) or {}) do
				table.insert(files, vim.fs.joinpath(name, file))
			end
		end
	end

	if ext ~= "*" then
		files = vim.tbl_filter(function(file)
			return file:match("[.]" .. ext .. "$")
		end, files)
	end

	return files
end

M.file_name = function(path, with_ext)
	if with_ext == nil then
		with_ext = true
	end

	local name = path:match("([^/]+)$")

	if with_ext then
		return name
	else
		return name:match("^(.-)%.[^.]*$")
	end
end

M.exists = function(path)
	return vim.fn.exists(path)
end
return M
