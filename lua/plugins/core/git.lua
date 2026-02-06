-- TODO: https://github.com/esmuellert/codediff.nvim

plugin("mini-git"):event("BufEnter"):on_require("mini.git")
plugin("mini-diff"):event("BufEnter"):on_require("mini.diff")
plugin("neogit")
	:opts({
		auto_refresh = true,
		disable_hint = true,
		integrations = {
			snacks = true,
		},
		graph_style = "unicode",
	})
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "g", function()
				-- TODO: make sure the tab is opened in last, currently 1, 2 would create 1, (neogit), 3
				-- I want 1, 2, (neogit)
				local ft = vim.bo.filetype

				local cwd = "%:p:h"
				if ft == "oil" then
					cwd = require("oil").get_current_dir() or cwd
				end
				require("neogit").open({
					cwd = cwd,
				})
			end, "Neogit"),
		}),
	})

plugin("gitsigns"):lazy(false):opts({
	current_line_blame_opts = {
		delay = 10,
	},
	preview_config = {
		border = "rounded",
	},
	current_line_blame_formatter = "<author>, <author_time:%R>",
	on_attach = function(bufnr)
		k:group("git", "<leader>g", {
			k:map("n", "w", k:require("gitsigns").toggle_current_line_blame(), "Toggle current line blame"),
		})
			:buffer(bufnr)
			:add()
	end,
})
