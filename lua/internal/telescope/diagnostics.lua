-- TODO: https://www.youtube.com/watch?v=xdXE1tOT-qg
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

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

local diagnostic_multi
---@param opts? table
diagnostic_multi = function(opts)
	opts = opts or {}

	opts.attach_mappings = function(_, map)
		local opts_fn = require("internal.telescope").opts_fn
		map(
			{ "n", "i" },
			"<C-g>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.bufnr == 0 then
					return false
				end
				opts.bufnr = nil
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-b>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.bufnr == 0 then
					return false
				end
				opts.bufnr = 0
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-e>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.severity == "ERROR" then
					return false
				end
				opts.severity = "ERROR"
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-w>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.severity == "WARN" then
					return false
				end
				opts.severity = "WARN"
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-h>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.severity == "HINT" then
					return false
				end
				opts.severity = "HINT"
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-i>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.severity == "INFO" then
					return false
				end
				opts.severity = "INFO"
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-a>",
			opts_fn(diagnostic_multi, function(prompt)
				if opts.severity == nil then
					return false
				end
				opts.severity = nil
				opts.default_text = prompt
				return opts
			end)
		)
		return true
	end

	opts.prompt_title = prompt_title(opts.bufnr, opts.severity)
	require("telescope.builtin").diagnostics(opts)
end

return diagnostic_multi
