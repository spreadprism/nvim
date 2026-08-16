local M = {}
---@param opts? { prompt?: string, model?: string, agent?: string|fun():string? }
function M.quick_chat(opts)
	return function()
		local util = require("opencode.util")

		local range
		if vim.fn.mode():match("[vV\022]") then
			local visual = util.get_visual_range()
			range = visual and { start = visual.start_line, stop = visual.end_line } or nil
		end

		-- Resolve now, not in the callback: `vim.ui.input` defers, by which
		-- point the current buffer/filetype is the input window's.
		local resolved = vim.tbl_extend("force", {}, opts or {})
		local preset = resolved.prompt
		resolved.prompt = nil
		if type(resolved.agent) == "function" then
			resolved.agent = resolved.agent()
		end

		local function send(input)
			if not input or input == "" then
				return
			end
			local prompt, ctx = util.parse_quick_context_args(input)
			resolved.context_config = ctx
			require("opencode.quick_chat").quick_chat(prompt, resolved, range)
		end

		if preset then
			return send(preset)
		end

		vim.ui.input({ prompt = "Quick Chat Message: ", win = { relative = "cursor" } }, send)
	end
end

return M
