local M = {}

local rg_available = vim.fn.executable("rg") == 1

local exec_cmd = function(cmd)
	local handle = io.popen(cmd)
	if handle == nil then
		return {}
	end
	local result = handle:read("*a")
	handle:close()
	local ans = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(ans, line)
	end
	return ans
end
---@param path string
---@return boolean | nil
M.exists = function(path)
	local lfs_available, lfs = pcall(require, "lfs")
	if lfs_available then
		return path ~= nil and lfs.attributes(path) ~= nil
	else
		local result = exec_cmd("[ -e " .. path .. " ] && echo 'exists'")
		return #result == 1 and result[1] == "exists"
	end
end

---@param path string
---@return boolean | nil
M.is_dir = function(path)
	local lfs_available, lfs = pcall(require, "lfs")
	if lfs_available then
		return M.exists(path) and lfs.attributes(path).mode == "directory"
	else
		local result = exec_cmd("[ -d " .. path .. " ] && echo 'dir'")
		return #result == 1 and result[1] == "dir"
	end
end

---@param path string
---@return boolean | nil
M.is_file = function(path)
	local lfs_available, lfs = pcall(require, "lfs")
	if lfs_available then
		return M.exists(path) and lfs.attributes(path).mode == "file"
	else
		local result = exec_cmd("[ -f " .. path .. " ] && echo 'file'")
		return #result == 1 and result[1] == "file"
	end
end

---@param path string
---@return table | nil
M.scan_dir = function(path, ...)
	if not M.is_dir(path) then
		return
	end
	local depth = arg[1] or 1
	local files = {}

	local lfs_available, lfs = pcall(require, "lfs")
	if lfs_available then
		for child in lfs.dir(path) do
			if child ~= "." and child ~= ".." then
				local child_path = vim.fs.joinpath(path, child)
				if M.is_dir(child_path) and (depth == "*" or type(depth) == "number" and depth > 1) then
					table.insert(files, table.unpack(M.scan_dir(child_path, depth - 1) or {}))
				elseif M.is_file(child_path) then
					table.insert(files, child_path)
				end
			end
		end
	else
		local tmp_files = exec_cmd("ls -1 " .. path)
		for _, file in ipairs(tmp_files) do
			local child_path = vim.fs.joinpath(path, file)
			if M.is_dir(child_path) and (depth == "*" or type(depth) == "number" and depth > 1) then
				table.insert(files, table.unpack(M.scan_dir(child_path, depth - 1) or {}))
			elseif M.is_file(child_path) then
				table.insert(files, child_path)
			end
		end
	end
	return files
end

---@param path string
---@param depth number | nil
---@param ext string | nil
M.get_files = function(path, depth, ext)
	depth = depth or 1
	ext = ext or "*"

	local files = M.scan_dir(path, depth)

	if ext ~= "*" then
		files = vim.tbl_filter(function(file)
			return file:match("[.]" .. ext .. "$")
		end, files)
	end
	return files
end

---@param path string
---@param with_extension boolean | nil
---@return table | nil
M.file_name = function(path, with_extension)
	with_extension = with_extension or false
	if M.is_file(path) then
		if with_extension then
			return path:match("^.+/(.+)$")
		else
			return path:match("^.+/(.+)%..+$")
		end
	end
end

---@param path string
---@return table | nil
M.file_extension = function(path)
	if M.is_file(path) then
		return path:match("^.+(%..+)$")
	end
end

return M
