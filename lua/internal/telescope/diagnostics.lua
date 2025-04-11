-- TODO: https://www.youtube.com/watch?v=xdXE1tOT-qg
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

local M = {}

---@param bufnr? integer
---@param severity? string
local function prompt_title(bufnr, severity)
	local name = ""
	if bufnr == 0 then
		name = "Buffer"
	else
		name = "Global"
	end

	name = name .. " diagnostics"

	if severity then
		name = name .. " (" .. severity .. ")"
	end

	return name
end

---@param opts? table
M.diagnostic_multi = function(opts)
	opts = opts or {}

	opts.attach_mappings = function(_, map)
		map({ "n", "i" }, "<C-g>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.bufnr = nil
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		map({ "n", "i" }, "<C-b>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.bufnr = 0
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		map({ "n", "i" }, "<C-e>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.severity = "ERROR"
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		map({ "n", "i" }, "<C-w>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.severity = "WARN"
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		map({ "n", "i" }, "<C-i>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.severity = "WARN"
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		map({ "n", "i" }, "<C-a>", function(prompt_bufnr)
			local prompt = state.get_current_line()
			actions.close(prompt_bufnr)
			opts.severity = nil
			opts.default_text = prompt
			opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
			M.diagnostic_multi(opts)
		end)
		return true
	end

	require("telescope.builtin").diagnostics(opts)
end

return M
