local M = {}

---@param key string
---@return string?
function M.get(key)
	return vim.env[key]
end

---@param key string
---@param val string
function M.set(key, val)
	vim.env[key] = val
end

function M.all()
	return vim.env
end

---@param keys string | string[]
function M.clear(keys)
	if type(keys) == "string" then
		keys = { keys }
	end
	for _, key in ipairs(keys) do
		vim.env[key] = nil
	end
end

---@param path string
---@return table
function M.read_env(path)
	if not vim.fn.filereadable(path) then
		return {}
	end

	local content = io.open(path, "r")
	if content == nil then
		return {}
	end

	local envs = {}
	for line in content:lines() do
		local key, val = line:match("^([^=]+)=(.*)$")
		if key ~= nil then
			envs[key] = val
		end
	end
	return envs
end

return M
