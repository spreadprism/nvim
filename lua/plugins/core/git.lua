-- TODO: https://github.com/esmuellert/codediff.nvim

plugin("mini-git"):event("DeferredUIEnter"):on_require("mini.git")
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

plugin("blame")
	:event("BufEnter")
	:opts({
		virtual_style = "float",
	})
	:keymaps(k:map("n", "<M-B>", k:require("internal.plugins.blame").buffer_blame(), "Toggle buffer blame"))
plugin("gitsigns"):lazy(false):opts({
	signcolumn = true,
	numhl = true,
	current_line_blame_opts = {
		delay = 10,
	},
	preview_config = {
		border = "rounded",
	},
	current_line_blame_formatter = "<author>, <author_time:%R>",
	on_attach = function(bufnr)
		k:opts({
			k:map("n", "<M-b>", k:require("internal.plugins.blame").line_blame(), "Toggle line blame"),
			k:group("git", "<leader>g", {}),
		})
			:buffer(bufnr)
			:add()
	end,
})
