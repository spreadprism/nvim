local M = {}

---@param path string | string[]
---@param ignore? string | string[]
function M.load_all(path, ignore)
	if type(path) == "string" then
		path = { path }
	end
	ignore = ignore or {}
	if type(ignore) == "string" then
		ignore = { ignore }
	end
	table.insert(ignore, "init")

	local parent_module = table.concat(path, ".")
	local pattern = "*/" .. table.concat(path, "/") .. "/*"

	for _, v in ipairs(vim.api.nvim_get_runtime_file(pattern, true)) do
		local name = vim.fn.fnamemodify(v, ":t:r")
		local add = true
		for _, i in ipairs(ignore) do
			if name == i then
				add = false
				break
			end
		end
		if add then
			local module_path = parent_module .. "." .. name
			local ok, msg = pcall(require, module_path)
			if not ok then
				print("Error loading plugins: " .. module_path .. " (cause=" .. msg .. ")")
			end
		end
	end
end

---@param cmd string
function M.cmd_on_click(cmd)
	return function(_, mouse_button, _)
		if mouse_button == "l" then
			vim.cmd(cmd)
		end
	end
end

local buffer_blacklist = {
	"neo-tree filesystem [1]",
	"[dap-repl]",
	"DAP Console",
	"DAP Watches",
	"NeogitStatus",
	"NeogitDiffView",
	"null",
	"DiffviewFilePanel",
	"pods",
}

local buffer_blacklist_contains = {
	"%[CodeCompanion%]",
}

local buffer_extension_blacklist = { "harpoon" }
local buffer_mode_blacklist = { "t" }

function M.cond_buffer_blacklist()
	local current_buffer_mode = vim.api.nvim_get_mode().mode
	local current_buffer_name = vim.fn.expand("%:t")
	local current_buffer_filetype = vim.bo.filetype

	-- INFO: Check if current buffer mode is in the blacklist
	for _, mode in ipairs(buffer_mode_blacklist) do
		if current_buffer_mode == mode then
			return false
		end
	end

	-- INFO: Don't need to check if buffer_name is empty
	if current_buffer_name == "" then
		return false
	end

	-- INFO: Check if current buffer name is in the blacklist
	for _, buffer_name in ipairs(buffer_blacklist) do
		if current_buffer_name == buffer_name then
			return false
		end
	end

	-- INFO: Check if current buffer name contains a blacklist
	for _, buffer_name in ipairs(buffer_blacklist_contains) do
		if string.find(current_buffer_name, buffer_name) then
			return false
		end
	end

	-- INFO: Check if current buffer extension is in the blacklist
	for _, buffer_extension in ipairs(buffer_extension_blacklist) do
		if current_buffer_filetype == buffer_extension then
			return false
		end
	end

	return true
end

return M
