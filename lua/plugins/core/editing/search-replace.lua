plugin("grug-far")
	:cmd("GrugFar")
	:keymaps({
		k:map("n", "<M-r>", k:require("grug-far").open(), "open replace window"),
		k:map("n", "<M-R>", function()
			require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
		end, "open replace window"),
		k:map("v", "<M-r>", k:require("grug-far").with_visual_selection(), "open replace window"),
		k:map("v", "<M-R>", function()
			require("grug-far").with_visual_selection({
				visualSelectionUsage = "auto-detect",
			})
		end, "open replace window"),
	})
	:opts({
		startInInsertMode = false,
	})
