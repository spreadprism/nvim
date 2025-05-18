workspace.init()

workspace.launch_configs_ft("go", {
	name = "debug",
	program = joinpath(cwd(), "main.go"),
})

workspace.launch_configs_ft("python", {
	name = "debug python",
	program = joinpath(cwd(), "test", "test.py"),
})
