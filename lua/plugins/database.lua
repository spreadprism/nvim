plugin("dbab")
	:opts({
		executor = "dadbod",
		layout = {
			{ "editor", "sidebar" },
			{ "result", "history" },
		},
		history = {
			on_select = "load",
			query_display = "short",
		},
		sidebar = {
			use_brand_icon = true,
			use_brand_color = true,
		},
		keymaps = {
			close = "<C-q>",

			editor = {
				next_tab = "<S-Right>",
				prev_tab = "<S-Left>",
				close_tab = "<localleader>q",
			},
		},
	})
	:lazydev({
		words = { "Dbab" },
	})
	:ft("sql")
	:cmd({ "Dbab" })
	:dep_on(plugin("dadbod"):opts(false))
	:keymaps(k:group("db", "<leader>b", {
		k:map("n", "b", function()
			vim.cmd("Dbab")
		end, "Open dbab"),
	}))
