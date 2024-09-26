plugin("stevearc/overseer.nvim"):event("VeryLazy"):config(function()
	require("overseer").setup({
		templates = { "cargo", "vscode" },
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
				["p"] = false,
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
	-- TODO: Add custom tasks logic
end)
