return {
	{
		name = "Current file",
		type = "go",
		request = "launch",
		program = "${file}",
	},
	{
		type = "go",
		name = "Debug test",
		request = "launch",
		mode = "test",
		program = "${file}",
	},
}
