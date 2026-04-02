plugin("jdtls"):opts(false)

local java_debug = nil

event.on_filetype("java", function()
  if java_debug == nil then
    java_debug = exec("java-debug-path")
  end

	require("jdtls").start_or_attach({
		cmd = { "jdtls" },
		root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", ".nvim.lua" }),
		settings = {
			java = {},
		},
		init_options = {
			bundles = {
        java_debug
      },
		},
	})
end)
