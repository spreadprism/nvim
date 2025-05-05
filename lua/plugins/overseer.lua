plugin("overseer")
	:on_require("overseer")
	:opts({
		templates = { "cargo", "vscode", "make", "shell" },
		component_aliases = {
			default = {
				"on_exit_set_status",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
			},
		},
		task_list = {
			bindings = {
				["?"] = "ShowHelp",
				["q"] = "Close",
				["<CR>"] = "RunAction",
				["o"] = "Open",
				["g?"] = false,
				["<C-e>"] = false,
				["<C-v>"] = false,
				["<C-s>"] = false,
				["<C-f>"] = false,
				["<C-q>"] = false,
				["p"] = "TogglePreview",
				["<C-l>"] = false,
				["<C-h>"] = false,
				["L"] = false,
				["H"] = false,
				["["] = false,
				["]"] = false,
				["{"] = false,
				["}"] = false,
				["<C-k>"] = false,
				["<C-j>"] = false,
			},
		},
	})
	:cmd({ "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerRunCmd" })
	:keys({
		kgroup("<leader>t", "tasks", {}, {
			kmap("n", "e", kcmd("OverseerToggle"), "Toggle explorer"),
			kmap("n", "t", kcmd("OverseerRun"), "Task run"),
			kmap("n", "r", function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true })
				if vim.tbl_isempty(tasks) then
					vim.notify("No tasks found", vim.log.levels.WARN)
				else
					overseer.run_action(tasks[1], "restart")
				end
			end, "rerun last task"),
			kmap("n", "f", kcmd("OverseerQuickAction open float"), "Open float last task"),
		}),
	})
