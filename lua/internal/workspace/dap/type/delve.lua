---@param config dap.Configuration
---@return dap.Configuration
return function(config)
	local new_configs = {}

	new_configs = vim.tbl_deep_extend("force", {}, config)

	if new_configs.program:match("%.go$") or (new_configs.autobuild == nil or new_configs.autobuild) then
		local program_no_filetype = new_configs.program:gsub("%.go$", "")
		local basename = vim.fn.fnamemodify(program_no_filetype, ":t")
		local name = "build(" .. new_configs.program .. ")"

		local cwd = vim.fn.getcwd()

		local input = new_configs.program

		local out
		if basename ~= "main" then
			out = vim.fs.joinpath(cwd, "dist", "dev", basename)
		else
			out = vim.fs.joinpath(cwd, "dist", "dev", vim.fn.fnamemodify(input, ":h:t"))
		end

		require("overseer").register_template({
			name = name,
			hide = true,
			builder = function()
				return {
					cmd = { "go", "build", "-o", out, input },
					cwd = cwd,
				}
			end,
		})

		new_configs.program = out
		new_configs.preLaunchTask = name
	end

	return new_configs
end
