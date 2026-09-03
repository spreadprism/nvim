plugin("mini-surround"):on_require("mini.surround"):event("DeferredUIEnter"):opts({
	mappings = {
		add = "sa",
		delete = "ds",
		replace = "cs",
	},
	n_lines = 50,
	search_method = "cover_or_next",
})
