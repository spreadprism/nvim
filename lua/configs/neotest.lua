require("neotest").setup({
	adapters = {
		require("neotest-python")({
			python = function()
				require("venv-selector").python()
			end,
		}),
		require("neotest-go")({
			recursive_run = true,
		}),
		require("neotest-rust"),
		require("neotest-vitest")({
			-- Filter directories when searching for test files. Useful in large projects (see Filter directories notes).
			filter_dir = function(name, rel_path, root)
				return name ~= "node_modules"
			end,
		}),
	},
})
