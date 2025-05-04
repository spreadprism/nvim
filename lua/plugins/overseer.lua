plugin("overseer")
	:on_require("overseer")
	:opts({
		templates = { "cargo", "cargo-dap", "vscode", "make", "shell" },
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
			kmap("n", "t", kcmd("OverseerToggle"), "Toggle UI"),
			kmap("n", "r", kcmd("OverseerRun"), "Task run"),
			kmap("n", "l", kcmd("OverseerQuickAction open float"), "Open float last task"),
		}),
	})
