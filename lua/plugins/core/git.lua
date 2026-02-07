plugin("mini-git"):on_require("mini.git"):cmd("Git")

local codediff = plugin("codediff.nvim"):on_require("codediff"):cmd("CodeDiff"):opts({
	explorer = {
		initial_focus = "modified",
	},
	keymaps = {
		view = {
			quit = "<C-q>",
			prev_file = "<Up>",
			next_file = "<Down>",
			prev_hunk = "<Left>",
			next_hunk = "<Right>",
		},
	},
})

plugin("neogit")
	:dep_on(codediff)
	:opts({
		auto_refresh = true,
		disable_hint = true,
		integrations = {
			snacks = true,
			codediff = true,
		},
		diff_viewer = "codediff",
		graph_style = "unicode",
	})
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "l", k:require("snacks.picker").git_log(), "git logs"),
			k:map("n", "g", function()
				vim.cmd("tablast")
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

plugin("gitsigns"):event("BufEnter"):opts({
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

plugin("blame")
	:event("BufEnter")
	:opts({
		virtual_style = "float",
		focus_blame = false,
	})
	:keymaps(k:map("n", "<M-B>", k:require("internal.plugins.blame").buffer_blame(), "Toggle buffer blame"))
