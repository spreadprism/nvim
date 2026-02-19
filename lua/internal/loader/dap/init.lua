local M = {}

---@param name string
---@param opts dap.Adapter|dap.AdapterFactory
function M:adapter(name, opts)
	return require("internal.loader.dap.adapter").adapter(name, opts)
end

---@param ft string
---@param config dap.Configuration
function M:config(ft, config)
	return require("internal.loader.dap.adapter")(ft, config)
end

---@param ft string
---@param ... string
function M:ft_link(ft, ...)
	require("internal.loader.dap.config").link(ft, ...)
end

return M
