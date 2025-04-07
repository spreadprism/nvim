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
				mappings = {
					{ key = "r", mode = "n", action = "refresh" },
					-- INFO: action_1 opens a note or executes a helper
					{ key = "<CR>", mode = "n", action = "action_1" }, -- INFO: open a note or execute a helper
					{ key = "<F2>", mode = "n", action = "action_2" }, -- INFO: rename
					{ key = "dd", mode = "n", action = "action_3" }, -- INFO: delete a note
					{ key = "<Tab>", mode = "n", action = "toggle" },
					{ key = "<CR>", mode = "n", action = "menu_confirm" },
					{ key = "y", mode = "n", action = "menu_yank" },
					{ key = "<Esc>", mode = "n", action = "menu_close" },
					{ key = "<C-q>", mode = "n", action = "menu_close" },
				},
			},
			result = {
				mappings = {
					-- next/previous page
					{ key = "yj", mode = "n", action = "yank_current_json" },
					{ key = "yj", mode = "v", action = "yank_selection_json" },
					{ key = "yJ", mode = "", action = "yank_all_json" },
					{ key = "yc", mode = "n", action = "yank_current_csv" },
					{ key = "yc", mode = "v", action = "yank_selection_csv" },
					{ key = "yC", mode = "", action = "yank_all_csv" },
					{ key = "<C-c>", mode = "", action = "cancel_call" },
				},
			},
			editor = {
				mappings = {
					{ key = "<Enter>", mode = "v", action = "run_selection" },
					{ key = "<Enter>", mode = "n", action = "run_file" },
					{ key = "<C-c>", mode = "", action = "cancel_call" },
				},
			},
			call_log = {
				mappings = {
					{ key = "<CR>", mode = "", action = "show_result" },
					{ key = "<C-c>", mode = "", action = "cancel_call" },
				},
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
