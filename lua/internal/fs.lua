local M = {}

---@param path string
---@return File | Directory
function M.Path(path) end
---@class Path
---@field path string
local Path = {}

function Path:Exists()
	local ok, _, code = os.rename(self.path, self.path)
	-- INFO: code-13 = Permission denied, but it exists
	return ok or code == 13
end

---@class File: Path
local File = {}

---@class Directory: Path
local Directory = {}

---@param dir string
---@return Path[], string?
function M.readDir(dir)
	if ~M.exists(dir) then
		return {}, dir .. " does not exist"
	end

	return {}, nil
end

---@param path string
---@return boolean
function M.exists(path)
	local ok, _, code = os.rename(path, path)
	-- INFO: code-13 = Permission denied, but it exists
	return ok or code == 13
end

---@param path string
function M.isDir(path) end

return M
