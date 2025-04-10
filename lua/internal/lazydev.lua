local M = {}

M.paths = {
	{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
	"nvim-dap",
	"nvim-dap-ui",
}

if exec("git config remote.origin.url"):gsub("\n", "") ~= "git@github.com:spreadprism/nvim.git" then
	table.insert(M.paths, (nixCats.configDir or "") .. "/lua/internal")
end

return M
