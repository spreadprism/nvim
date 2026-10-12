local tasks = require("internal.overseer")

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
				["<CR>"] = { "keymap.open", opts = { dir = "float" }, desc = "Open task output in float" },
				["<M-Tab>"] = { "keymap.open", opts = { dir = "tab" }, desc = "Open task output in tab" },
				["e"] = "keymap.run_action",
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
		k:map("n", "<M-t>", tasks.run_task, "run task"),
		k:map("n", "<leader>!", tasks.run_cmd, "run cmd"),
		k:map("n", "r", tasks.run_task, "run task"):ft("OverseerList"),
		k:group("tasks", "<leader>t", {
			k:map("n", "e", k:require("overseer").toggle(), "tasks explorer"),
			k:map("n", "o", tasks.open_last_float, "open last task in float"),
			k:map("n", "l", tasks.rerun_last, "rerun last task"),
		}),
	})
	:after(function()
		event.on_plugin("nvim-dap", function()
			require("overseer").enable_dap()
		end)
	end)
