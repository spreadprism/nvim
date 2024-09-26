local json = require("internal.json")
local fs = require("internal.fs")

local M = {}

local SAVE_FILE_PATH = vim.fs.joinpath(vim.fn.stdpath("config"), ".nvim.state.json")

local load_state = function()
	local state = nil
	if fs.exists(SAVE_FILE_PATH) then
		local file = io.open(SAVE_FILE_PATH, "r")
		if file == nil then
			print("Failed to load state")
			return {}
		end
		local content = file:read("*a")
		file:close()

		state = json.decode(content, 1)
	end
	return state or {}
end

local master_table = load_state()

local save_state = function()
	local encoded_json = json.encode(master_table)
	local file, err = io.open(SAVE_FILE_PATH, "w")
	if file == nil then
		print("Failed to save state:" .. err)
		return {}
	end
	file:write(encoded_json)
	file:close()
end

---@param key string
---@param val any
M.set = function(key, val)
	master_table[key] = val
	save_state()
end

---@param key string
M.get = function(key)
	local val = master_table[key]
	if val == json.null then
		return nil
	else
		return val
	end
end

return M
