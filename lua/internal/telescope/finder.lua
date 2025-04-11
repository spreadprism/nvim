-- TODO: https://www.youtube.com/watch?v=xdXE1tOT-qg
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

---@param opts table
---@param base_buffer string
local function prompt_title(opts, base_buffer)
	local name = ""
	if opts.search_dirs and opts.search_dirs[1] == base_buffer then
		name = "Buffer finder"
	else
		if opts.search_dirs == nil then
			name = "Global finder"
		else
			local clean_search_dir = vim.tbl_map(function(path)
				return path:gsub("/$", "")
			end, opts.search_dirs)
			name = "Dir finder (" .. table.concat(clean_search_dir, ", ") .. ")"
		end
	end

	return name
end

local finder_multi
---@param opts? table
---@param base_buffer string
finder_multi = function(opts, base_buffer)
	opts = opts or {}

	local fn_finder = function(o)
		finder_multi(o, base_buffer)
	end

	opts.attach_mappings = function(_, map)
		local opts_fn = require("internal.telescope").opts_fn
		map(
			{ "n", "i" },
			"<C-b>",
			opts_fn(fn_finder, function(prompt)
				if opts.search_dirs and opts.search_dirs[1] == base_buffer then
					return false
				end
				opts.search_dirs = { base_buffer }
				opts.default_text = prompt
				return opts
			end)
		)
		map(
			{ "n", "i" },
			"<C-g>",
			opts_fn(fn_finder, function(prompt)
				if opts.search_dirs == nil then
					return false
				end
				opts.search_dirs = nil
				opts.default_text = prompt
				return opts
			end)
		)
		map({ "n", "i" }, "<C-d>", function()
			require("dir-telescope.util").get_dirs({ disable_devicons = true, show_preview = false }, fn_finder)
		end)
		map({ "n", "i" }, "<C-f>", actions.to_fuzzy_refine)
		return true
	end
	opts.prompt_title = prompt_title(opts, base_buffer)
	require("telescope.builtin").live_grep(opts, base_buffer)
end

return finder_multi
