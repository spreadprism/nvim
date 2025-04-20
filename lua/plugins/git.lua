plugin("mini.diff"):event_defer()
plugin("git-conflict")
	:for_cat("git")
	:event_defer()
	:opts({
		default_mappings = false,
		default_commands = false,
		disable_diagnostics = true,
	})
	:setup(function()
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function(args)
				if not internal.plugin_loaded("git-conflict") then
					return
				end
				vim.defer_fn(function()
					local count = require("git-conflict").conflict_count(args.buf)
					if count > 0 then
						kgroup("<leader>c", "choose", { buffer = args.buf }, {
							kmap("n", "c", function()
								require("git-conflict").choose("ours")
							end, "choose current"),
							kmap("n", "i", function()
								require("git-conflict").choose("theirs")
							end, "choose incoming"),
							kmap("n", "b", function()
								require("git-conflict").choose("both")
							end, "choose both"),
							kmap("n", "n", function()
								require("git-conflict").choose("none")
							end, "choose none"),
						})
					else
						require("internal.keymap").buf_del_keymap(
							args.buf,
							"n",
							"<leader>cc",
							"<leader>ci",
							"<leader>cb",
							"<leader>cn"
						)
					end
				end, 100)
			end,
		})
	end)
plugin("diffview.nvim")
	:for_cat("git")
	:cmd("DiffviewOpen")
	:on_plugin("neogit")
	:on_require("diffview")
	:opts({
		enhanced_diff_hl = true,
		view = {
			default = {
				disable_diagnostics = true,
				winbar_info = true,
			},
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
		file_panel = {
			listing_style = "list",
		},
		hooks = {
			view_opened = function(view)
				vim.cmd("wincmd l")
			end,
			view_enter = function()
				require("lualine").hide({
					place = { "winbar" },
					unhide = false,
				})
			end,
			view_leave = function()
				require("lualine").hide({
					place = { "winbar" },
					unhide = true,
				})
				require("neogit").dispatch_refresh()
			end,
		},
		keymaps = {
			disable_defaults = true,
			file_history_panel = require("internal.diffview").file_history_keys,
			file_panel = require("internal.diffview").file_panel_keys,
			view = require("internal.diffview").view_keys,
		},
	})
	:keys(kgroup("<leader>g", "git", {}, {
		kmap("n", "d", kcmd("DiffviewOpen"), "open diffview"),
	}))
plugin("neogit")
	:for_cat("git")
	:on_require("neogit")
	:cmd("Neogit")
	:opts({
		disable_hint = true,
		integrations = {
			telescope = true,
			diffview = true,
		},
		graph_style = "unicode",
	})
	:keys(kgroup("<leader>g", "git", {}, {
		kmap("n", "g", kcmd("Neogit"), "open neogit"),
	}))
plugin("gitsigns.nvim")
	:for_cat("git")
	:event_buffer_enter()
	:on_require("gitsigns")
	:opts({
		current_line_blame_opts = {
			delay = 10,
		},
		preview_config = {
			border = "rounded",
		},
		current_line_blame_formatter = "<author>, <author_time:%R>",
		on_attach = function(bufnr)
			kmap("n", "<M-b>", kcmd("Gitsigns blame_line"), "blame hover", { buffer = bufnr })
			kgroup("<leader>g", "git", { buffer = bufnr }, {
				kmap("n", "b", kcmd("Gitsigns toggle_current_line_blame"), "Toggle current line blame"),
				kmap("n", "B", kcmd("Gitsigns blame"), "Toggle blame"),
			})
		end,
	})
	:setup(function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "gitsigns-blame" },
			callback = function(args)
				kopts({ buffer = args.buf }, {
					kmap("n", "<cr>", function()
						local hash = vim.split(vim.api.nvim_get_current_line(), " ", { trimempty = true })[2]
						require("neogit.buffers.commit_view").open_or_run_in_window(hash)
						vim.defer_fn(function()
							vim.cmd("q")
						end, 50)
					end, "open in gitsigns"),
				})
			end,
		})
	end)
