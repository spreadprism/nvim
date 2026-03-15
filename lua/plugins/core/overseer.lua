plugin("overseer")
	:opts({
		dap = false,
		templates = { "cargo", "vscode", "make", "just", "shell" },
		form = {
			border = "rounded",
		},
		task_win = {
			border = "rounded",
		},
		component_aliases = {
			default = {
				"on_exit_set_status",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
			},
		},
		task_list = {
			direction = "right",
			keymaps = {
				["<C-q>"] = "<CMD>close<CR>",
				["<Up>"] = "keymap.prev_task",
				["<Down>"] = "keymap.next_task",
				["o"] = { "keymap.open", opts = { dir = "float" }, desc = "Open task output in float" },
			},
		},
	})
	:cmd({
		"OverseerRun",
		"OverseerToggle",
		"OverseerQuickAction",
		"OverseerRunCmd",
	})
	:keymaps({
		k:map("n", "<M-t>", k:require("overseer").toggle(), "toggle overseer"),
		k:map("n", "r", k:require("overseer").run_task(), "run task"):ft("OverseerList"),
	})
	:after(function()
		event.on_plugin("nvim-dap", function()
			require("overseer").enable_dap()
		end)
	end)
