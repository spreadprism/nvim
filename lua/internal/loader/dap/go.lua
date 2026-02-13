local M = {}

local Dap = require("internal.loader.dap").Dap

---@class DapGo: Dap
M.DapGo = Dap:new({ spec = { type = "go" } })

M.DapGo.spec.enrich_config = function(config, on_config)
	local final_config = vim.deepcopy(config)

	final_config.mode = config.mode or "exec"

	Dap.spec.enrich_config(config, on_config)
end

---@param program string
---@return DapGo
function M.DapGo:program(program)
	self.spec.program = program
	return self
end

return M
