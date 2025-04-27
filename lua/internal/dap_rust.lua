local M = {}

--- generate overseer template
---@param config_name string
---@param args table
---@param cwd string
local function generate_template(config_name, args, cwd)
	local template_name = config_name .. "_prebuild"
	local template = {
		name = template_name,
		builder = function()
			return {
				cmd = { "cargo" },
				args = args,
				cwd = cwd,
			}
		end,
	}

	return template_name, template
end

function M.cargo(config)
	local final_config = vim.deepcopy(config)
	local cargo = final_config.cargo

	local args = cargo.args or {}
	local cwd = cargo.cwd or cwd()

	local template_name, template = generate_template(config.name, args, cwd)
	require("overseer").register_template(template)
	final_config.preLaunchTask = template_name
end

return M
