---@class cargoConfiguration
---@field args string[]
---@field cwd? string

---@param config dap.Configuration
---@param on_config fun(config: dap.Configuration)
return function(config, on_config)
	local overseer = require("overseer")
	local dap = require("dap")
	local final_config = vim.deepcopy(config)
	final_config.cargo = nil

	if config.cargo then
		---@type cargoConfiguration
		local cargo = config.cargo
		if cargo.args[1] ~= "build" and cargo.args ~= "test" then
			vim.notify("expected `build` or `test`, received" .. cargo.args[1], vim.log.levels.ERROR)
			final_config.program = dap.ABORT
			on_config(final_config)
			return
		end
		local build_path = joinpath(cwd(), ".cargo-build.json")
		local cmd = string.format("cargo %s --message-format=json > %s", table.concat(cargo.args, " "), build_path)
		overseer.run_template({
			name = "shell",
			params = {
				name = final_config.name .. " (BUILD)",
				cmd = cmd,
				cwd = cargo.cwd or cwd(),
				components = { "default", "unique" },
			},
			autostart = false,
			---@param task overseer.Task
		}, function(task, err)
			if err ~= nil then
				final_config.program = dap.ABORT
				vim.notify("Failed to start cargo build: " .. err, vim.log.levels.ERROR)
				on_config(final_config)
				return
			end
			task:subscribe("on_complete", function(_, status)
				if status == overseer.STATUS.SUCCESS then
					final_config.program =
						exec(string.format("cat %s | jq -c '.executable // empty' | jq -r | head -n 1", build_path))
				else
					final_config.program = dap.ABORT
					vim.notify("Cargo build failed: ", vim.log.levels.ERROR)
				end
				on_config(final_config)
				os.remove(build_path)
			end)
			task:start()
		end)
	end
end
