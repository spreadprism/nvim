local diff = plugin("sindrets/diffview.nvim"):event("VeryLazy"):opts({})
plugin("NeogitOrg/neogit")
	:dependencies({
		"nvim-lua/plenary.nvim",
		diff,
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
