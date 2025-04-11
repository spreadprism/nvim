local M = {}
local state = require("telescope.actions.state")
local actions = require("telescope.actions")

---@param finder fun(table)
---@param fn fun(prompt): table | boolean
function M.opts_fn(finder, fn)
	---@param prompt_bufnr number
	return function(prompt_bufnr)
		local prompt = state.get_current_line()
		local opts = fn(prompt)
		if type(opts) == "table" or opts == nil then
			actions.close(prompt_bufnr)
			finder(opts or {})
		end
	end
end

M.diagnostics = require("internal.telescope.diagnostics")
M.finder = require("internal.telescope.finder")

return M
