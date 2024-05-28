-- Ripgrep wrapper
local M = {}

local execute_rg = function(cmd)
	-- executes rg command and returns a newlines separated list of results
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

M.rg = function(args, base_path)
	base_path = base_path or vim.fn.getcwd()
	return execute_rg("rg " .. args .. " " .. "$(realpath " .. base_path .. ")")
end

local ignore_patterns = {
	".git/*",
	"**/node_modules/*",
	"**/target/*",
	"/dist/*",
	"/.nx/*",
	".next/*",
	".venv",
	"**/__pycache__/*",
	"**/.pytest_cache/*",
	"**/.ruff_cache/*",
}

M.find_files_cmd = function()
	local find_files_rg = {
		"rg",
		"-uuu",
		"--files",
		"--hidden",
	}

	for _, pattern in pairs(ignore_patterns) do
		table.insert(find_files_rg, "--glob")
		table.insert(find_files_rg, "!" .. pattern)
	end

	return find_files_rg
end
return M
