plugin("nvim-dbee")
	:for_cat("db")
	:cmd("Dbee")
	:on_require("dbee")
	:dep_on("nui-nvim")
	:config(function()
		require("dbee").setup({
			sources = {
				require("internal.db").source,
			},
			drawer = {
				mappings = {},
			},
			result = {
				mappings = {},
			},
			editor = {
				mappings = {},
			},
			call_log = {
				mappings = {},
			},
			window_layout = require("dbee.layouts").Default:new({
				drawer_width = 30,
				result_height = 10,
				call_log_height = 10,
			}),
		})
	end)
	:setup(function()
		-- BUG: https://github.com/kndndrj/nvim-dbee/issues/120
		local tools = require("dbee.layouts.tools")
		---@diagnostic disable-next-line: duplicate-set-field
		tools.save = function()
			return nil
		end
		tools.restore = tools.save
	end)
	:keys(kgroup("<leader>b", "dBee", {}, {
		kmap("n", "b", function()
			vim.cmd("tabnew")
			vim.cmd("Dbee")
		end, "Open dbee"),
	}))
