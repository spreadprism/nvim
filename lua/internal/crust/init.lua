local M = {}

--- Modules holding custom tool specs, each keyed by tool name.
---@type string[]
local sources = {
	"internal.crust.just",
	"internal.crust.kagi",
}

--- Register every custom tool renderer with crust. Safe to call more than once.
function M.register_tools()
	local ok, tools = pcall(require, "crust.ui.chat.tools")
	if not ok then
		return
	end

	for _, source in ipairs(sources) do
		for name, spec in pairs(require(source)) do
			tools.register(name, spec)
		end
	end
end

return M
