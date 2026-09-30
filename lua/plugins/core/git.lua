local diffview = plugin("diffview")
	:cmd({
		"DiffviewOpen",
		"DiffviewToggle",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewDiffFiles",
		"DiffviewFocusFiles",
		"DiffviewToggleFiles",
		"DiffviewRefresh",
	})
	:opts(function()
		local actions = require("diffview.actions")

		--- unwraps our Keymap specs into diffview's `{ mode, lhs, rhs, opts }` entries
		---@param keymaps Keymap[]
		local function entries(keymaps)
			return vim.tbl_map(function(keymap)
				local spec = keymap.spec
				return { spec.mode, spec[1], spec[2], { desc = spec.desc } }
			end, keymaps)
		end

		-- maps that apply in every diffview context
		local shared = {
			k:map("n", "<C-q>", k:cmd("DiffviewClose"), "Quit"),
		}

		-- context -> extra maps, merged on top of `shared`
		local per_context = {
			view = {
				k:map("n", "<tab>", actions.select_next_entry, "Next file"),
				k:map("n", "<s-tab>", actions.select_prev_entry, "Previous file"),
				k:map("n", "gf", actions.goto_file_edit, "Open file in previous tabpage"),
				k:map("n", "<leader>e", actions.focus_files, "Focus file panel"),
				k:map("n", "<leader>b", actions.toggle_files, "Toggle file panel"),
			},
			file_panel = {
				k:map("n", "<cr>", actions.select_entry, "Open diff for entry"),
				k:map("n", "j", actions.next_entry, "Next entry"),
				k:map("n", "k", actions.prev_entry, "Previous entry"),
				k:map("n", "s", actions.toggle_stage_entry, "Stage/unstage entry"),
				k:map("n", "R", actions.refresh_files, "Refresh"),
			},
			file_history_panel = {
				k:map("n", "<cr>", actions.select_entry, "Open diff for entry"),
				k:map("n", "j", actions.next_entry, "Next entry"),
				k:map("n", "k", actions.prev_entry, "Previous entry"),
				k:map("n", "y", actions.copy_hash, "Copy commit hash"),
			},
		}

		---@type table<string, any>
		local keymaps = { disable_defaults = true }
		for _, ctx in ipairs({
			"view",
			"diff1",
			"diff1_inline",
			"diff2",
			"diff3",
			"diff4",
			"file_panel",
			"file_history_panel",
			"option_panel",
			"help_panel",
			"commit_log_panel",
		}) do
			keymaps[ctx] = entries(vim.list_extend(vim.list_slice(shared), per_context[ctx] or {}))
		end

		---@type DiffviewConfig.user
		local opts = {
			enhanced_diff_hl = true,
			use_icons = true,
			keymaps = keymaps,
			view = {
				-- the only view type that enables the winbar by default
				merge_tool = { winbar_info = false },
			},
			file_panel = {
				listing_style = "tree",
				win_config = {
					position = "right",
					width = 35,
				},
			},
			hooks = {
				diff_buf_win_enter = function(bufnr, winid, ctx)
					pcall(vim.api.nvim_exec_autocmds, "BufReadPost", {
						buffer = bufnr,
						group = "treesitter_context_update",
						modeline = false,
					})
				end,
				view_closed = function()
					local ok, tsc = pcall(require, "treesitter-context")
					if ok and tsc.enabled() then
						tsc.enable()
					end
				end,
			},
		}
		return opts
	end)
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "h", k:cmd("DiffviewFileHistory %"), "open file history for buffer"),
			k:map("x", "h", function()
				-- leave visual mode so that the '< and '> marks point at the current selection
				vim.cmd("normal! " .. vim.keycode("<esc>"))
				vim.cmd(string.format("%d,%dDiffviewFileHistory", vim.fn.line("'<"), vim.fn.line("'>")))
			end, "open file history for selection"),
			k:map("n", "H", function()
				local path = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand("%:p:h")
				local root = vim.fs.root(path ~= "" and path or vim.fn.getcwd(), ".git") or vim.fn.getcwd()
				vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(root))
			end, "open file history for workspace"),
		}),
	})

plugin("atlas")
	:opts(function()
		---@type AtlasConfig
		return {
			ui = {
				statusline = false,
				picker = "snacks",
			},
			pulls = {
				git_transport = "ssh",
				default_merge_method = "squash",
				---@diagnostic disable-next-line: assign-type-mismatch
				diff = "DiffviewOpen",
			},
		}
	end)
	:event("DeferredUIEnter")

plugin("neogit")
	:dep_on(diffview)
	:opts({
		auto_refresh = true,
		disable_hint = true,
		integrations = {
			snacks = true,
			diffview = true,
		},
		diff_viewer = "diffview",
		graph_style = "unicode",
	})
	:cmd("Neogit")
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "g", function()
				vim.cmd("tablast")
				local path = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand("%:p:h")
				require("neogit").open({ cwd = vim.fs.root(path ~= "" and path or vim.fn.getcwd(), ".git") })
			end, "Neogit"),
		}),
	})

plugin("gitsigns")
	:cmd("Gitsigns")
	:event("BufEnter")
	:opts({
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
				k:map("n", "<M-b>", k:cmd("Gitsigns toggle_current_line_blame"), "Toggle line blame"),
				-- k:map("n", "<M-B>", k:cmd("Gitsigns blame"), "open blame window"),
			})
				:buffer(bufnr)
				:add()
		end,
	})
	:after(function()
		vim.schedule(function()
			vim.cmd("redrawstatus!")
		end)
	end)

plugin("blame")
	:cmd("BlameToggle")
	:opts({
		mappings = {},
	})
	:keymaps({
		k:map("n", "<M-B>", k:cmd("BlameToggle"), "Toggle blame"),
	})
	:after(function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "BlameViewOpened",
			callback = function(event)
				local blame_type = event.data
				local get_hash = function()
					local window = require("blame").last_opened_view
					if not window then
						return nil
					end
					local row, _ = unpack(vim.api.nvim_win_get_cursor(window.blame_window))
					local commit = window.blamed_lines[row]
					return commit.hash
				end
				if blame_type == "window" then
					vim.defer_fn(function()
						local buf = vim.api.nvim_get_current_buf()
						k:opts({
							k:map("n", "<CR>", function()
								local hash = get_hash()
								if hash then
									require("blame").last_opened_view:close()
									local NeogitCommitView = require("neogit.buffers.commit_view")
									local view = NeogitCommitView.new(hash)
									view:open("tab")
								end
							end, "open commit"),
							k:map("n", "d", function()
								local hash = get_hash()
								if hash then
									require("blame").last_opened_view:close()
									vim.cmd(":DiffviewOpen " .. hash .. "^.." .. hash)
								end
							end, "open commit"),
						})
							:buffer(buf)
							:add()
					end, 50)
				end
			end,
		})
	end)

plugin("worktrunk")
	:event("DeferredUIEnter")
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "w", k:require("worktrunk").pick(), "worktree"),
			k:map("n", "c", k:require("worktrunk").create(), "create worktree"),
			k:map("n", "x", k:require("worktrunk").delete(), "delete worktree"),
			k:map("n", "m", k:require("worktrunk").merge(), "merge worktree"),
		}),
	})
	:opts({
		hooks = {
			on_switch = function()
				vim.schedule(function()
					---@diagnostic disable-next-line: param-type-mismatch
					pcall(vim.cmd, "Gitsigns refresh")
					vim.cmd("redrawstatus!")
					vim.cmd("redrawtabline")
				end)
			end,
		},
	})
