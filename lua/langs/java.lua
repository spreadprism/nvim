plugin("jdtls"):opts(false)

event.on_filetype("java", function()
	require("jdtls").start_or_attach({
		cmd = { "jdtls" },
		root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", ".nvim.lua" }),
		settings = {
			java = {},
		},
		init_options = {
			bundles = {
				nixCats("overlays")["java-debug"].path,
			},
		},
	})
end)
