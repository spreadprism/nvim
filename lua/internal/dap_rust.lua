local M = {}

function M.cargo(config)
	local final_config = vim.deepcopy(config)
	local cargo = final_config.cargo

	local args = cargo.args or {}
	local cwd = cargo.cwd or cwd()

	local template_name = final_config.name .. "_build"
	local executable = ""
	-- local template = {
	-- 	name = template_name,
	-- 	builder = function()
	-- 		return {
	-- 			cmd = { "cargo" },
	-- 			args = vim.list_extend(args, { "--message-format=json" }),
	-- 			cwd = cwd,
	-- 			components = {
	-- 				desc = "parse cargo build output",
	-- 				editable = false,
	-- 				serializable = false,
	-- 				constructor = function()
	-- 					return {
	-- 						on_result = function(self, task, result)
	-- 							vim.print(result)
	-- 						end,
	-- 					}
	-- 				end,
	-- 			},
	-- 		}
	-- 	end,
	-- }
	--
	-- require("overseer").register_template(template)
	-- final_config.preLaunchTask = template_name
	final_config.program = ""

	final_config.cargo = nil
	return final_config
end

return M
