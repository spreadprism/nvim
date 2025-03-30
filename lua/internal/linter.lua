local M = {}

---@type Plugin?
local linter_plugin = nil

local function get_linter_plugin()
	if linter_plugin == nil then
		linter_plugin = plugin("nvim-lint"):on_require("lint"):triggerUIEnter()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("lint").try_lint()
			end,
		})
	end
	return linter_plugin
end

---@param filetypes string | string[]
---@param linters string | table
function M.linter(filetypes, linters)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end
	if type(linters) == "string" then
		linters = { linters }
	end

	for _, ft in ipairs(filetypes) do
		get_linter_plugin()
			:opts({
				linters_by_ft = {
					[ft] = linters,
				},
			})
			:after(function(_)
				require("lint").linters_by_ft = get_linter_plugin().opts_table.linters_by_ft
			end)
	end
end

return M
