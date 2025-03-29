plugin("diffview.nvim")
	:triggerUIEnter()
	:for_cat("git")
	:on_plugin("neogit")
	:on_require("diffview")
	:opts({
		enhanced_diff_hl = true,
		view = {
			default = {
				layout = "diff2_horizontal",
			},
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
		keymaps = {
			disable_defaults = true,
			file_history_panel = require("internal.diffview").file_history_keys,
			file_panel = require("internal.diffview").file_panel_keys,
			view = require("internal.diffview").view_keys,
		},
	})
	:keys(keymapGroup("<leader>g", "git", {
		keymap("n", "d", keymapCmd("DiffviewOpen"), "open diffview"),
	}))
plugin("neogit")
	:for_cat("git")
	:cmd("Neogit")
	:opts({
		disable_hint = true,
		integrations = {
			telescope = true,
			diffview = true,
		},
		graph_style = "unicode",
	})
	:keys(keymapGroup("<leader>g", "git", {
		keymap("n", "g", keymapCmd("Neogit"), "open neogit"),
	}))
plugin("gitsigns.nvim"):for_cat("git"):triggerUIEnter():on_require("gitsigns"):opts({
	current_line_blame_opts = {
		delay = 10,
	},
	current_line_blame_formatter = "<author>, <author_time:%R>",
	on_attach = function(bufnr)
		local opts = { buffer = bufnr }
		keymapGroup("<leader>g", "git", {
			keymap("n", "b", keymapCmd("Gitsigns toggle_current_line_blame"), "Toggle current line blame", opts),
			keymap("n", "B", keymapCmd("Gitsigns blame"), "Open gitblame", opts),
		})
	end,
})
