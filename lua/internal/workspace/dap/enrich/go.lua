---@class GoConfiguration : Configuration
---@field program string
---@field mode? "debug"|"test"|"exec"|"remote"
---@field outputMode? "remote"
---@field profile "dev"|"prod"|string

--- Returns true when `path` is a go source file declaring `package main`.
---@param path string
---@return boolean
local function is_main_file(path)
	if not path:match("%.go$") or path:match("_test%.go$") then
		return false
	end

	local fd = io.open(path, "r")
	if fd == nil then
		return false
	end

	local in_block_comment = false
	local found = false
	for line in fd:lines() do
		if in_block_comment then
			local _, stop = line:find("%*/")
			if stop then
				in_block_comment = false
				line = line:sub(stop + 1)
			else
				line = ""
			end
		end

		line = line:gsub("//.*$", "")
		if line:find("/%*") then
			in_block_comment = true
			line = line:gsub("/%*.*$", "")
		end

		if line:match("^%s*package%s+main%s*$") then
			found = true
			break
		end

		-- the package clause is the first statement of a file: stop as soon as
		-- another package is declared
		if line:match("^%s*package%s+[%w_]+") then
			break
		end
	end
	fd:close()

	return found
end

--- Resolves `program` to the directory holding the `main` package, or nil when
--- `program` is not a go main package (e.g. an already built binary).
---@param program string
---@return string|nil
local function main_package_dir(program)
	local stat = vim.uv.fs_stat(program)
	if stat == nil then
		return nil
	end

	if stat.type == "file" then
		return is_main_file(program) and vim.fs.dirname(program) or nil
	end

	if stat.type ~= "directory" then
		return nil
	end

	for name, type in vim.fs.dir(program) do
		if type == "file" and is_main_file(vim.fs.joinpath(program, name)) then
			return program
		end
	end

	return nil
end

---@param workspace Workspace
---@param config GoConfiguration
---@return GoConfiguration
local function convert_main_to_build(workspace, config)
	--- check if given program is a go file or go dir containing main
	--- if it is, check if there is a preLaunchTask, if there isn't generate the prelaunch task
	--- if there is, send an error message to the user that it makes no sense
	local input = vim.fs.abspath(config.program)

	local pkg_dir = main_package_dir(input)
	if pkg_dir == nil then
		return config
	end

	if config.preLaunchTask ~= nil and config.preLaunchTask ~= "" then
		vim.notify(
			string.format(
				"DAP: %s points at the go main package %q and already defines preLaunchTask %q.\n"
					.. "Either point `program` at a prebuilt binary or drop the preLaunchTask.",
				config.name or "configuration",
				vim.fn.fnamemodify(input, ":~:."),
				config.preLaunchTask
			),
			vim.log.levels.ERROR,
			{ title = "Go DAP" }
		)
		return config
	end

	local dirname = vim.fs.basename(pkg_dir)
	local output = vim.fs.joinpath(workspace.workspaceDir, "dist", config.profile, dirname)
	local task_name = "build(" .. input .. ")"

	require("overseer").register_template({
		name = task_name,
		hide = true,
		builder = function()
			return {
				-- build the whole main package, not just the single file
				cmd = { "go", "build", "-o", output, pkg_dir },
				cwd = workspace.workspaceDir,
			}
		end,
	})

	config.program = output
	config.mode = "exec"
	config.preLaunchTask = task_name

	return config
end

---@param workspace Workspace
---@param config GoConfiguration
---@return GoConfiguration
local function enrich_build(workspace, config)
	config = convert_main_to_build(workspace, config)
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
