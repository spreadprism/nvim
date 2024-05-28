local M = {}

local lfs_available, lfs = pcall(require, "lfs")
local rg_available = vim.fn.executable("rg") == 1

if not lfs_available then
	if Os == Windows then
		print("Windows detected and lfs not available, buckle your seatbelts...")
	else
		-- TODO: Implement native os functions
		print("Linux detected and lfs not available. I still haven't implemented native, buckle your seatbelts...")
	end
end

---@param path string
---@return boolean | nil
M.exists = function(path)
	if lfs_available then
		return path ~= nil and lfs.attributes(path) ~= nil
	end
end

---@param path string
---@return boolean | nil
M.is_dir = function(path)
	if lfs_available then
		return M.exists(path) and lfs.attributes(path).mode == "directory"
	end
end

---@param path string
---@return boolean | nil
M.is_file = function(path)
	if lfs_available then
		return M.exists(path) and lfs.attributes(path).mode == "file"
	end
end

---@param path string
---@return table | nil
M.scan_dir = function(path, ...)
	if not M.is_dir(path) then
		return
	end
	local depth = arg[1] or 1
	if lfs_available then
		local files = {}
		for child in lfs.dir(path) do
			if child ~= "." and child ~= ".." then
				local child_path = vim.fs.joinpath(path, child)
				if M.is_dir(child_path) and (depth == "*" or type(depth) == "number" and depth > 1) then
					table.insert(files, table.unpack(M.scan_dir(child_path, depth - 1, glob) or {}))
				elseif M.is_file(child_path) then
					table.insert(files, child_path)
				end
			end
		end
		return files
	end
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
