---@type overseer.ComponentFileDefinition
return {
	desc = "parse message-format=json for cargo",
	constructor = function(params)
		return {
			on_complete = function(self, task, status, result)
				vim.g.result = result
				for _, r in ipairs(result) do
					if r.executable then
						vim.g.overseer_cargo_exec = r.executable
					end
				end
			end,
		}
	end,
}
