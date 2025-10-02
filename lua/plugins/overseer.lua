plugin("overseer")
	:on_require("overseer")
	:opts({
		dap = false,
		templates = { "cargo", "vscode", "make", "just", "shell" },
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
				["<C-q>"] = "Close",
				["<CR>"] = "RunAction",
				["o"] = "OpenFloat",
				["p"] = "TogglePreview",
				["e"] = "Edit",
				["r"] = "Restart",
				["g?"] = false,
				["<C-e>"] = false,
				["<C-v>"] = false,
				["<C-s>"] = false,
				["<C-f>"] = false,
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
		task_editor = {
			bindings = {
				i = {
					["<CR>"] = "NextOrSubmit",
					["<C-s>"] = "Submit",
					["<Tab>"] = "Next",
					["<S-Tab>"] = "Prev",
					["<C-q>"] = "Cancel",
				},
				n = {
					["<CR>"] = "Submit",
					["<Tab>"] = "Next",
					["<S-Tab>"] = "Prev",
					["<C-q>"] = "Cancel",
					["?"] = "ShowHelp",
				},
			},
		},
	})
	:cmd({ "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerRunCmd" })
	:keys({
		kmap("n", "<leader><leader>", kcmd("OverseerRun shell"), "execute shell command"),
		kmap("n", "<M-t>", kcmd("OverseerQuickAction open float"), "task console"),
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
		}),
	})
