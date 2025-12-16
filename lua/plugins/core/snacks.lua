plugin("snacks"):opts({
	image = {
		enabled = true,
	},
	inputs = {
		enabled = true,
	},
	picker = {
		main = {
			file = false,
		},
		enabled = true,
		matcher = {
			frecency = true,
		},
	},
})
