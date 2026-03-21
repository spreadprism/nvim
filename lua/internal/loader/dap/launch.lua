---@class Configuration : dap.Configuration
---@field args? string[]
---@field env? table<string, string>
---@field cwd? string

---@class GoConfiguration : Configuration
---@field program string
---@field mode? "debug"|"test"|"exec"|"remote"
---@field outputMode? "remote"

local M = {}

---@param opts GoConfiguration
---@return GoConfiguration
function M.go(opts)
	return vim.tbl_deep_extend("force", {
		mode = "exec",
		outputMode = "remote",
	}, opts)
end

for lang, fn in pairs(M) do
	M[lang] = function(opts)
		opts = fn(opts)

		opts = vim.tbl_deep_extend("keep", opts, {
			request = "launch",
			cwd = vim.fn.getcwd(),
		})

		return opts
	end
end

---@param lang string
---@param opts table
---@return dap.Configuration
---@overload fun(lang: "go", opts: GoConfiguration|GoConfiguration[]): dap.Configuration[]
function M.launch(lang, opts)
	if M[lang] then
		opts = M[lang](opts)
	end
	return opts
end

return M
