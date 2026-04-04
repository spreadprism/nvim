---@class GoConfiguration : Configuration
---@field program string
---@field mode? "debug"|"test"|"exec"|"remote"
---@field outputMode? "remote"
---@field profile "dev"|"prod"|string

---@param workspace Workspace
---@param config GoConfiguration
---@return GoConfiguration
local function enrich_build(workspace, config)
	local dirname
	local program = vim.fs.abspath(config.program)

	-- if is dir
	if vim.fn.isdirectory(program) == 1 then
		dirname = vim.fs.basename(dirname)

		-- check if there is a main.go or dirname.go inside
		local main_go = vim.fs.joinpath(program, "main.go")
		local dirname_go = vim.fs.joinpath(program, dirname .. ".go")

		if vim.fn.filereadable(main_go) == 1 then
			program = main_go
		elseif vim.fn.filereadable(dirname_go) == 1 then
			program = dirname_go
		else
			return config
		end
	else
		dirname = vim.fs.basename(vim.fs.dirname(program))
	end

	local input = program
	local output = vim.fs.joinpath(workspace.workspaceDir, "dist", config.profile, dirname)
	local task_name = "build(" .. input .. ")"

	require("overseer").register_template({
		name = task_name,
		hide = true,
		builder = function()
			return {
				cmd = { "go", "build", "-o", output, input },
				cwd = workspace.workspaceDir,
			}
		end,
	})

	config.program = output
	config.preLaunchTask = task_name

	return config
end

---@param workspace Workspace
---@param config GoConfiguration
---@return GoConfiguration|GoConfiguration[]
return function(workspace, config)
	if config.program == nil or config.program == "" then
		vim.notify("DAP: No program specified for " .. config.name, vim.log.levels.ERROR, { title = "Go DAP" })
		return {}
	end
	config = vim.tbl_deep_extend("force", {
		mode = "exec",
		outputMode = "remote",
		profile = "dev",
	}, config)

	config = enrich_build(workspace, config)

	return config
end
