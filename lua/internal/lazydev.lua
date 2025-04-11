local M = {}

M.paths = {
	{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
	"nvim-dap",
	"nvim-dap-ui",
}

local s = vim.split(cwd(), "/", { trimempty = true })
if s[#s] ~= "nvim" then
	table.insert(M.paths, (nixCats.configDir or "") .. "/lua/internal")
end

return M
