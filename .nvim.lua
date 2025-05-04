workspace.init()

workspace.launch_configs_ft("go", {
	name = "debug",
	program = joinpath(cwd(), "main.go"),
})
