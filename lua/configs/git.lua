local diff = plugin("sindrets/diffview.nvim"):event("VeryLazy"):opts({})
plugin("NeogitOrg/neogit")
	:dependencies({
		diff,
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	})
	:cmd("Neogit")
	:opts({
		disable_hint = true,
		integrations = {
			telescope = true,
			diffview = true,
		},
		graph_style = "unicode",
		commit_editor = {
			-- staged_diff_split_kind = "vsplit_left",
		},
	})
