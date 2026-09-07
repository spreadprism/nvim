local M = {}

--- PI has no public API to register tool renderers: the `renderers` table in
--- `pi.ui.chat.tools` is a file-local upvalue. `get_renderer` is exported though,
--- so we wrap it and let our own renderers answer first.
---@type table<string, pi.ToolRenderer>
M.renderers = vim.tbl_extend("error", {}, require("internal.pi.tools.kagi"))

--- Wrap `pi.ui.chat.tools.get_renderer` so `M.renderers` takes precedence.
--- Tool names may be namespaced by the backend (e.g. `mcp__kagi__kagi_extract`),
--- so we also match on the trailing segment.
function M.register()
	local ok, tools = pcall(require, "pi.ui.chat.tools")
	if not ok or tools._custom_renderers then
		return
	end

	local get_renderer = tools.get_renderer
	tools._custom_renderers = true

	tools.get_renderer = function(name)
		local custom = M.renderers[name]

		if not custom and type(name) == "string" then
			local tail = name:match("([%w_]+)$")
			custom = tail and M.renderers[tail] or nil
		end

		return custom or get_renderer(name)
	end
end

return M
