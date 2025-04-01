plugin("nvim-lint"):on_require("lint"):after(function()
	require("lint").linters_by_ft = require("internal.linter").linter_by_ft
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
	local goci = require("lint").linters.golangcilint
	-- BUG: nvim-lint doesn't work with golangcilint v2
	goci.args = {
		"run",
		"--output.json.path=stdout",
		"--issues-exit-code=0",
		"--show-stats=false",
		"--output.text.print-issued-lines=false",
		"--output.text.print-linter-name=false",
		function()
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
		end,
	}
end)
