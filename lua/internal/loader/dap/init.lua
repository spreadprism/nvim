local M = {}

---@class Dap
---@field spec dap.Configuration
M.Dap = {
	spec = {
		---@param config dap.Configuration
		---@param on_config fun(config: dap.Configuration)
		enrich_config = function(config, on_config)
			local final_config = vim.deepcopy(config)

			final_config.request = config.request or "launch"
			final_config.cwd = config.cwd or vim.fn.getcwd()

			on_config(final_config)
		end,
	},
}

---@param d? Dap
function M.Dap:new(d)
	d = d or {}
	setmetatable(d, self)
	self.__index = self
	return d
end

---@param name string
function M.Dap:name(name)
	self.spec.name = name
	return self
end

---@param type string
function M.Dap:type(type)
	self.spec.type = type
	return self
end

---@param request "launch"|"attach"
function M.Dap:request(request)
	self.spec.request = request
	return self
end

-- TODO: preLaunchTask when overseer

return M
