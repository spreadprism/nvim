-- TODO: neogit
-- TODO: gitsigns.nvim
-- TODO: https://github.com/esmuellert/codediff.nvim
plugin("neogit")
	:opts({
		auto_refresh = true,
		disable_hint = true,
		integrations = {
			snacks = true,
			diffview = true,
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
