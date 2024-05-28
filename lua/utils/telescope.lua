local M = {}

M.find_files = function()
	return require("telescope.builtin").find_files
end

M.resume = function()
	return require("telescope.builtin").resume
end

---@param buffer_only boolean
M.fuzzy_live_grep = function(buffer_only)
	if buffer_only then
		return require("telescope.builtin").current_buffer_fuzzy_find
	else
		return function()
			require("telescope.builtin").grep_string({
				shorten_path = true,
				only_sort_text = true,
				search = "",
			})
		end
	end
end

---@param buffer_only boolean
M.live_grep = function(buffer_only)
	if buffer_only then
		return function()
			require("telescope.builtin").live_grep({ search_dirs = { vim.fn.expand("%:p") } })
		end
	else
		return require("telescope.builtin").live_grep
	end
end

return M
