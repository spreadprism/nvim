require("overseer").setup({
	templates = { "cargo", "vscode", "make", "npm" },
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
keymapGroup("<leader>t", "tasks", {
	keymap("n", "t", keymapCmd("OverseerToggle"), "Toggle UI"),
	keymap("n", "b", keymapCmd("OverseerToggle"), "Trigger build"),
	keymap("n", "r", keymapCmd("OverseerRun"), "Task run"),
	keymap("n", "l", keymapCmd("OverseerQuickAction open float"), "Open float last task"),
})
