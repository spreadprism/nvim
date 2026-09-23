--- Directory the linter should run from.
---
--- The attached language server knows the project root, but it may not have
--- initialised yet (or there may be none at all), so fall back to the usual
--- markers instead of waiting for it. Waiting used to mean a `defer_fn(1000)`
--- that both delayed the diagnostics by a second and ran the whole lint twice.
---@param buf integer
---@return string
local function lint_root(buf)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		if client.name ~= "copilot" and client.name ~= "ast_grep" and client.root_dir then
			return client.root_dir
		end
	end

	local bufname = vim.api.nvim_buf_get_name(buf)
	if bufname ~= "" then
		local root = vim.fs.root(buf, { ".git", ".nvim.lua" })
		if root then
			return root
		end
	end

	return vim.fn.getcwd()
end

plugin("lint"):event("DeferredUIEnter"):opts(false):after(function()
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("lint_on_save", { clear = true }),
		callback = function(args)
			require("lint").try_lint(nil, { cwd = lint_root(args.buf) })
		end,
	})
end)

lsp("ast_grep")
	:cmd({
		"ast-grep",
		"lsp",
		"--config",
		vim.fs.joinpath(nixCats.configDir, "lua", "ast_grep_rules", "sgconfig.yml"),
	})
	:root_markers({ vim.fn.getcwd(), ".git", "sgconfig.yaml", "sgconfig.yml" })
	:display(false)
