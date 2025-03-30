local M = {}

---@param ft string
function M.clear(ft)
	require("dap").configurations[ft] = {}
end

return M
