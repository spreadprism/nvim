---@class RustConfiguration : Configuration
---@field pack? string
---@field profile? "debug"|"release"

local function enrich_build(workspace, config)
	local task_name = "build(" .. config.pack .. ")"

	local cmd = { "cargo", "build", "-p", config.pack }
	if config.profile == "release" then
		table.insert(cmd, "--release")
	end

	require("overseer").register_template({
		name = task_name,
		hide = true,
		builder = function()
			return {
				cmd = cmd,
				cwd = workspace.workspaceDir,
			}
		end,
	})

	config.program = vim.fs.joinpath(workspace.workspaceDir, "target", config.profile, config.pack)
	config.preLaunchTask = task_name

	return config
end

---@param workspace Workspace
---@param config GoConfiguration
---@return RustConfiguration|RustConfiguration[]
return function(workspace, config)
	config = vim.tbl_deep_extend("force", {
		pack = vim.fs.basename(workspace.workspaceDir),
		profile = "debug",
		console = "internalConsole",
	}, config)

	local output = exec("cargo metadata --format-version 1 --no-deps | jq -r '.packages[].name'")
	-- split output by newline
	local packages = vim.split(output, "\n", { plain = true })

	if not vim.tbl_contains(packages, config.pack) then
		vim.notify(
			"DAP: Package " .. config.pack .. " not found in workspace",
			vim.log.levels.ERROR,
			{ title = "Rust DAP" }
		)
		return {}
	end

	config = enrich_build(workspace, config)

	return config
end
