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

return M
