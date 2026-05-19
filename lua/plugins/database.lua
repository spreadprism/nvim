plugin("dbab")
	:opts({
		executor = "dadbod",
		layout = "wide",
	})
	:cmd({ "Dbab" })
	:dep_on(plugin("dadbod"):opts(false))
