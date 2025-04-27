local M = {}

function M.cargo(config)
	local final_config = vim.deepcopy(config)
	local cargo = final_config.cargo

	local args = cargo.args or {}
	local cwd = cargo.cwd or cwd()

	local template_name = final_config.name .. "_build"
	local msg_path = joinpath(cwd, template_name .. "_msg.json")
	local template = {
		name = template_name,
		builder = function()
			return {
				cmd = { "cargo" },
				args = vim.list_extend(args, { "--message-format=json", ">>", msg_path }),
				cwd = cwd,
			}
		end,
	}

	require("overseer").register_template(template)
	final_config.preLaunchTask = template_name
	final_config.program = function()
		local file = io.open(msg_path, "r")
		if file == nil then
			return require("dap").ABORT
		end
		---@type string
		local json = file:read("*a")

		local executables = {}
		-- vim
		-- 	.iter(json:gmatch("([^\n]*)\n?'"))
		-- 	:map(function(value)
		-- 		local is_json, artifact = pcall(vim.fn.json_decode, value)
		-- 		---@diagnostic disable-next-line: redundant-return-value
		-- 		return is_json, artifact
		-- 	end)
		-- 	:filter(function(is_json, artifact)
		-- 		-- only process artifact if it's valid json object and it is a compiler artifact
		-- 		return is_json and type(artifact) == "table" and artifact.reason == "compiler-artifact"
		-- 	end)
		-- 	---@param artifact table
		-- 	:each(function(_, artifact)
		-- 		local is_binary = vim.list_contains(artifact.target.crate_types, "bin")
		-- 		local is_build_script = vim.list_contains(artifact.target.kind, "custom-build")
		-- 		local is_test = ((artifact.profile.test == true) and (artifact.executable ~= nil))
		-- 			or vim.list_contains(artifact.target.kind, "test")
		-- 		-- only add executable to the list if we want a binary debug and it is a binary
		-- 		-- or if we want a test debug and it is a test
		-- 		if (args[1] == "build" and is_binary and not is_build_script) or (args[1] == "test" and is_test) then
		-- 			table.insert(executables, artifact.executable)
		-- 		end
		-- 	end)

		if #executables <= 0 then
			vim.notify("Multiple compilation artifacts are not supported.", vim.log.levels.ERROR)
			return
		end
		if #executables > 1 then
			vim.notify("Multiple compilation artifacts are not supported.", vim.log.levels.ERROR)
			return
		end

		exec("rm " .. msg_path)
		return executables[1]
	end

	final_config.cargo = nil
	return final_config
end

return M
