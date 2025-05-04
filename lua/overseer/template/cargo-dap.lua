return {
	name = "cargo dap",
	tags = { require("overseer").TAG.BUILD },
	params = {
		args = { type = "list", delimiter = " " },
		cwd = { optional = true },
	},
	builder = function(params)
		return {
			name = "build",
			cmd = {
				"cargo",
				unpack(vim.list_extend(params.args, { "--message-format=json", ">", ".cargo-build.json" })),
			},
			-- args = vim.list_extend(params.args, { "--message-format=json", "--quiet" }),
			cwd = params.cwd,
			components = {
				"default",
				{
					"on_output_parse",
					parser = {
						"extract_json",
					},
				},
			},
		}
	end,
}
