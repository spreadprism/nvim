local M = {}

local function base(opts)
	return vim.tbl_deep_extend("force", {
		request = "launch",
		cwd = vim.fn.getcwd(),
	}, opts)
end
---@param opts GoConfiguration
---@return GoConfiguration
function M.go(opts)
	return vim.tbl_deep_extend("force", {
		mode = "exec",
		outputMode = "remote",
	}, base(opts))
end

---@param lang string
---@param opts table
---@return dap.Configuration|dap.Configuration[]
---@overload fun(lang: "go", opts: GoConfiguration|GoConfiguration[]): dap.Configuration|dap.Configuration[]
function M.launch(lang, opts)
	if not vim.islist(opts) then
		opts = { opts }
	end

	local new_opts = {}
	for _, opt in ipairs(opts) do
		opt.type = lang
		if M[lang] then
			opt = M[lang](opt)
		end

		table.insert(new_opts, opt)
	end

	return new_opts
end

-- launch()

return M
