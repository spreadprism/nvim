local M = {}

M.paths = {
	{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
	"nvim-dap",
	"nvim-dap-ui",
}
if cwd() ~= joinpath(XDG_CONFIG, "nxim") then
	table.insert(M.paths, (nixCats.configDir or "") .. "/lua/internal")
end

return M
