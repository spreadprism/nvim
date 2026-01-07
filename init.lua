vim.loader.enable()

for _, path in ipairs(vim.api.nvim_get_runtime_file("*/inits/*.lua", true)) do
	local name = vim.fn.fnamemodify(path, ":t:r")
	local module_path = "inits." .. name
	local ok, msg = pcall(require, module_path)
	if not ok then
		print("Error loading plugins: " .. module_path .. " (cause=" .. msg .. ")")
	end
end
