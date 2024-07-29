local fs = require("utils.filesystem")
local json = require("utils.json")

local M = {}

local SAVE_STATE_DIR = vim.fs.joinpath(vim.fn.stdpath("data"), "save_state")

if not fs.exists(SAVE_STATE_DIR) then
	vim.cmd("silent !mkdir " .. SAVE_STATE_DIR)
end

local SAVE_FILE_PATH = vim.fs.joinpath(SAVE_STATE_DIR, "master_table.json")

M.load_state = function()
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

local master_table = M.load_state()

M.save_state = function()
	local encoded_json = json.encode(master_table)
	local file, err = io.open(SAVE_FILE_PATH, "w")
	if file == nil then
		print("Failed to save state:" .. err)
		return {}
	end
	file:write(encoded_json)
	file:close()
end

M.set_state = function(key, val)
	master_table[key] = val
	M.save_state()
end

M.get_state = function(key)
	local val = master_table[key]
	if val == json.null then
		return {}
	else
		return val
	end
end

return M
