plugin("nvim-dbee"):for_cat("db"):cmd("Dbee"):on_require("dbee"):dep_on("nui-nvim"):opts({
	sources = {
		require("internal.db").source,
	},
})
