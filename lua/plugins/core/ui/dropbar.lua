plugin("dropbar"):event("UIEnter"):opts(function()
	return {
		bar = {
			enable = function(buf, win, _)
				buf = vim._resolve_bufnr(buf)
				if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
					vim.print("here")
					return false
				end

				if
					not vim.api.nvim_buf_is_valid(buf)
					or not vim.api.nvim_win_is_valid(win)
					or vim.fn.win_gettype(win) ~= ""
					or vim.wo[win].winbar ~= ""
					or vim.bo[buf].ft == "help"
				then
					vim.print("here 2")
					return false
				end

				local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
				if stat and stat.size > 1024 * 1024 then
					vim.print("here 3")
					return false
				end

				return vim.tbl_contains({ "markdown", "oil" }, vim.bo[buf].ft)
					or pcall(vim.treesitter.get_parser, buf)
					or not vim.tbl_isempty(vim.lsp.get_clients({
						bufnr = buf,
						method = "textDocument/documentSymbol",
					}))
			end,
			sources = function(buf, _)
				local sources = require("dropbar.sources")
				if vim.bo[buf].buftype == "terminal" then
					return { sources.terminal }
				else
					return { sources.path }
				end
			end,
		},
		sources = {
			path = {
				relative_to = function(_, win)
					local ok, cwd = pcall(vim.fn.getcwd, win)
					if not ok then
						cwd = vim.fn.getcwd()
					end

					return vim.fn.fnamemodify(cwd, ":h")
				end,
			},
		},
	}
end)
