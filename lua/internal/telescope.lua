local M = {}

local ignore = {
	".git/*",
	"**/node_modules/*",
	"**/target/*",
	"**/.cache/*",
	"/dist/*",
	"/.nx/*",
	".next/*",
	".venv",
	"**/__pycache__/*",
	"**/.pytest_cache/*",
	"**/.ruff_cache/*",
}
M.find_command = {
	"rg",
	"-uuu",
	"--files",
	"--hidden",
	unpack(vim.tbl_map(function(pattern)
		return "--glob=!" .. pattern
	end, ignore)),
}

M.zf_native = {
	file = {
		-- override default telescope file sorter
		enable = true,

		-- highlight matching text in results
		highlight_results = true,

		-- enable zf filename match priority
		match_filename = true,

		-- optional function to define a sort order when the query is empty
		initial_sort = nil,

		-- set to false to enable case sensitive matching
		smart_case = true,
	},
	generic = {
		enable = false,
	},
}
M.fzf = {
	override_file_sorter = false,
}

---@param global? boolean
function M.live_grep(global)
	if global == nil then
		global = false
	end

	if global then
		return function()
      require("telescope.builtin").live_grep({
        prompt_title = 'grep global'
      })
		end
	else
		return function()
			require("telescope.builtin").live_grep({
        search_dirs = { vim.fn.expand("%:p") },
        prompt_title = 'grep buffer',
      })
		end
	end
end

return M
