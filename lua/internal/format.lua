local M = {}

---@type Plugin?
local format_plugin = nil

local function get_formatter_plugin()
	if format_plugin == nil then
		format_plugin = plugin("conform.nvim"):on_require("conform"):triggerUIEnter():opts({
			formatters_by_ft = {
				["*"] = { "trim_whitespace" },
			},
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end
	return format_plugin
end

---@param filetypes string | string[]
---@param formatters string | table
function M.formatter(filetypes, formatters)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end
	if type(formatters) == "string" then
		formatters = { formatters }
	end

	for _, ft in ipairs(filetypes) do
		get_formatter_plugin():opts({
			formatters_by_ft = {
				[ft] = formatters,
			},
		})
	end
end

return M
