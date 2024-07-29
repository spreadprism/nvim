local fs = require("utils.filesystem")
local APPROVED_KEY = "approved_nvim_lua"
local BLOCKED_KEY = "blocked_nvim_lua"

local approved = get_saved_val(APPROVED_KEY)
if approved == nil then
	approved = {}
	set_saved_val(APPROVED_KEY, approved)
end
local blocked = get_saved_val(BLOCKED_KEY)
if blocked == nil then
	blocked = {}
	set_saved_val(BLOCKED_KEY, blocked)
end

local function load_project_conf()
	local cwd = vim.fn.getcwd()
	local external_file = vim.fs.joinpath(cwd, ".nvim.lua")

	if not fs.exists(external_file) then
		return
	end

	if vim.tbl_contains(blocked, external_file) then
		return
	end

	if not vim.tbl_contains(approved, external_file) then
		local choice = vim.fn.confirm("Found .nvim.lua in project root, add to approved list?", "&Yes\n&No")

		if choice == 1 then
			---@diagnostic disable-next-line: param-type-mismatch
			table.insert(approved, external_file)
			set_saved_val(APPROVED_KEY, approved)
		else
			---@diagnostic disable-next-line: param-type-mismatch
			table.insert(blocked, external_file)
			set_saved_val(BLOCKED_KEY, approved)
			return
		end
	end

	dofile(external_file)
end

load_project_conf()
