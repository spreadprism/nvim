plugin("diffview")
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

		--- diffview only exposes a *toggle*, so make `s`/`u` directional by
		--- running the toggle only when the entry is on the expected side
		---@param stage boolean true to stage, false to unstage
		local function stage_entry(stage)
			return function()
				local view = require("diffview.lib").get_current_view() --[[@as DiffView?]]
				if not view or not view.infer_cur_file then
					return
				end

				-- a multi-file selection toggles per entry, which is already
				-- directional for each of them
				local selected = view.panel.get_selected_files and view.panel:get_selected_files() or {}
				if #selected > 0 then
					return actions.toggle_stage_entry()
				end

				local entry = view:infer_cur_file(true)
				if not entry then
					return
				end

				local staged = entry.kind == "staged"
				if staged == stage then
					return
				end

				actions.toggle_stage_entry()
			end
		end

		--- `]c`/`[c` only work in real diff windows; the `diff1_inline` layout
		--- renders with `diff=false` and needs diffview's own hunk walker
		---@param next boolean
		local function jump_hunk(next)
			return function()
				if vim.wo.diff then
					vim.cmd("normal! " .. (next and "]c" or "[c"))
					return
				end

				local jump = next and actions.next_inline_hunk or actions.prev_inline_hunk
				jump()
			end
		end

		--- `actions.toggle_files` opens the panel *and* focuses it; keep the
		--- cursor in the diff instead
		local function toggle_files()
			local view = require("diffview.lib").get_current_view() --[[@as DiffView?]]
			if view and view.panel then
				view.panel:toggle(false)
			end
		end

		-- maps that apply in every diffview context
		local shared = {
			k:map("n", "<C-q>", k:cmd("DiffviewClose"), "Quit"),
		}

		--- `<C-q>` closes the whole view, except in the auxiliary panels where it
		--- should only dismiss the panel itself
		local function panel(context)
			return {
				k:map("n", "<C-q>", actions.close, "Close panel"),
				k:map("n", "<localleader>?", actions.help(context), "Help"),
			}
		end

		--- pull the hunk under the cursor (or in the visual range) from a side
		---@param context string|string[] keymap groups listed by the help panel
		---@param base? boolean the BASE window only exists in 4-way layouts
		local function hunk_choosing(context, base)
			local maps = {
				k:map("nx", "<localleader>do", actions.diffget("ours"), "Take hunk from OURS"),
				k:map("nx", "<localleader>dt", actions.diffget("theirs"), "Take hunk from THEIRS"),
				k:map("n", "<localleader>?", actions.help(context), "Help"),
			}

			if base then
				table.insert(maps, k:map("nx", "<localleader>db", actions.diffget("base"), "Take hunk from BASE"))
			end

			return maps
		end

		-- conflict resolution, only meaningful in the layouts of the merge tool
		local conflict = {
			k:map("n", "]x", actions.next_conflict, "Next conflict"),
			k:map("n", "[x", actions.prev_conflict, "Previous conflict"),
			-- the conflict under the cursor
			k:map("n", "<localleader>co", actions.conflict_choose("ours"), "Choose OURS"),
			k:map("n", "<localleader>ct", actions.conflict_choose("theirs"), "Choose THEIRS"),
			k:map("n", "<localleader>cb", actions.conflict_choose("base"), "Choose BASE"),
			k:map("n", "<localleader>ca", actions.conflict_choose("all"), "Choose all versions"),
			k:map("n", "<localleader>cx", actions.conflict_choose("none"), "Delete conflict region"),
			-- every conflict in the file
			k:map("n", "<localleader>cO", actions.conflict_choose_all("ours"), "Choose OURS for the file"),
			k:map("n", "<localleader>cT", actions.conflict_choose_all("theirs"), "Choose THEIRS for the file"),
			k:map("n", "<localleader>cB", actions.conflict_choose_all("base"), "Choose BASE for the file"),
			k:map("n", "<localleader>cA", actions.conflict_choose_all("all"), "Choose all versions for the file"),
			k:map("n", "<localleader>cX", actions.conflict_choose_all("none"), "Delete all conflict regions"),
			-- replace the whole MERGED buffer with one side, markers and all
			k:map("n", "<localleader>cso", actions.conflict_choose_side("ours"), "Take the whole OURS side"),
			k:map("n", "<localleader>cst", actions.conflict_choose_side("theirs"), "Take the whole THEIRS side"),
			k:map("n", "<localleader>csb", actions.conflict_choose_side("base"), "Take the whole BASE side"),
		}

		-- context -> extra maps, merged on top of `shared`
		local per_context = {
			-- single window: nothing to `:diffget` from, markers only
			diff1 = vim.list_extend(vim.list_slice(conflict), {
				k:map("n", "<localleader>?", actions.help({ "view", "diff1" }), "Help"),
			}),
			diff3 = vim.list_extend(vim.list_slice(conflict), hunk_choosing({ "view", "diff3" })),
			diff4 = vim.list_extend(vim.list_slice(conflict), hunk_choosing({ "view", "diff4" }, true)),
			diff2 = {
				k:map("n", "<localleader>?", actions.help({ "view", "diff2" }), "Help"),
			},
			diff1_inline = {
				-- the inline layout has no second window for `:diffget`, it splices
				-- the old side back in from the renderer's cached hunks instead
				k:map("nx", "<localleader>do", actions.diffget_inline, "Take hunk from the old side"),
				k:map("n", "<localleader>?", actions.help({ "view", "diff1", "diff1_inline" }), "Help"),
			},
			option_panel = panel("option_panel"),
			help_panel = {
				k:map("n", "<C-q>", actions.close, "Close panel"),
			},
			commit_log_panel = {
				k:map("n", "<C-q>", actions.close, "Close panel"),
			},
			view = {
				k:map("n", "<Down>", actions.select_next_entry, "Next file"),
				k:map("n", "<Up>", actions.select_prev_entry, "Previous file"),
				k:map("n", "<Right>", jump_hunk(true), "Next diff"),
				k:map("n", "<Left>", jump_hunk(false), "Previous diff"),
				k:map("n", "<localleader>s", stage_entry(true), "Stage file"),
				k:map("n", "<localleader>u", stage_entry(false), "Unstage file"),
				k:map("n", "gf", actions.goto_file_edit, "Open file in previous tabpage"),
				k:map("n", "-", toggle_files, "Toggle file panel"),
			},
			file_panel = {
				k:map("n", "<cr>", actions.select_entry, "Open diff for entry"),
				k:map("n", "j", actions.next_entry, "Next entry"),
				k:map("n", "k", actions.prev_entry, "Previous entry"),
				k:map("n", "s", stage_entry(true), "Stage entry"),
				k:map("n", "u", stage_entry(false), "Unstage entry"),
				k:map("n", "S", actions.stage_all, "Stage all"),
				k:map("n", "U", actions.unstage_all, "Unstage all"),
				k:map("n", "R", actions.refresh_files, "Refresh"),
				k:map("n", "<localleader>?", actions.help("file_panel"), "Help"),
			},
			file_history_panel = {
				k:map("n", "<cr>", actions.select_entry, "Open diff for entry"),
				k:map("n", "j", actions.next_entry, "Next entry"),
				k:map("n", "k", actions.prev_entry, "Previous entry"),
				k:map("n", "y", actions.copy_hash, "Copy commit hash"),
				k:map("n", "<localleader>?", actions.help("file_history_panel"), "Help"),
			},
		}

		-- tabpages whose diff window still needs `focus_diff` re-asserted
		---@type table<integer, true>
		local focus_pending = {}

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
				merge_tool = {
					winbar_info = false,
					layout = "diff3_mixed",
					disable_diagnostics = true,
					focus_diff = true,
				},
				default = {
					layout = "diff2_horizontal",
					focus_diff = true,
				},
				file_history = {
					layout = "diff2_horizontal",
					focus_diff = true,
				},
			},
			file_panel = {
				listing_style = "list",
				win_config = {
					position = "right",
					width = 35,
				},
			},
			hooks = {
				-- `focus_diff` happens inside an async `set_file`, so anything
				-- scheduled after it wins; re-assert it once per opened view
				view_opened = function(view)
					focus_pending[view.tabpage] = true
				end,
				diff_buf_win_enter = function(bufnr, winid, ctx)
					pcall(vim.api.nvim_exec_autocmds, "BufReadPost", {
						buffer = bufnr,
						group = "treesitter_context_update",
						modeline = false,
					})

					local tabpage = vim.api.nvim_get_current_tabpage()
					if focus_pending[tabpage] then
						focus_pending[tabpage] = nil
						vim.schedule(function()
							-- the *main* window, not whichever side entered first:
							-- for a 3-way layout that's MERGED, not OURS
							local view = require("diffview.lib").get_current_view() --[[@as StandardView?]]
							local main = view and view.cur_layout and view.cur_layout:get_main_win()
							local target = main and main.id or winid

							if vim.api.nvim_win_is_valid(target) then
								vim.api.nvim_set_current_win(target)
							end
						end)
					end
				end,
				view_closed = function(view)
					focus_pending[view.tabpage] = nil

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
			k:map("n", "s", k:cmd("DiffviewOpen"), "current worktree status"),
			k:map("n", "d", function()
				local worktrunk = require("worktrunk")

				-- the left side of the range: the branch of the worktree nvim sits
				-- in, or the detached HEAD when there is none
				local current = worktrunk.current()
				local ours = current and current.branch or "HEAD"

				-- worktrees only: `branches`/`remotes` would also list refs that
				-- aren't checked out anywhere
				worktrunk.pick({
					title = "Diff against",
					branches = true,
					remotes = true,
				}, function(worktree)
					local theirs = worktree.branch or (worktree.head and worktree.head.sha)
					if not theirs then
						return vim.notify("worktree has no branch to diff against", vim.log.levels.WARN)
					end

					if theirs == ours then
						-- diffing a ref against itself yields an empty view; show the
						-- working tree instead
						return vim.cmd("DiffviewOpen")
					end

					-- branch names may contain `%`, `#` and spaces, all expanded by `:cmd`
					vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(ours .. ".." .. theirs))
				end)
			end, "diff against worktree"),
			k:map("n", "h", k:cmd("DiffviewFileHistory %"), "open file history for buffer"),
			k:map("x", "h", function()
				-- leave visual mode so that the '< and '> marks point at the current selection
				vim.cmd("normal! " .. vim.keycode("<esc>"))
				vim.cmd(string.format("%d,%dDiffviewFileHistory", vim.fn.line("'<"), vim.fn.line("'>")))
			end, "open file history for selection"),
		}),
	})
	:on_highlights(function(highlights, colors)
		-- the panel groups are links (`diffAdded`, `DiagnosticSignWarn`, ...) and
		-- inherit their background; redefine them so the panel stays flat
		local panel = {
			DiffviewFilePanelTitle = { fg = colors.blue, bold = true },
			DiffviewFilePanelRootPath = { fg = colors.blue, bold = true },
			DiffviewFilePanelCounter = { fg = colors.purple, bold = true },
			DiffviewFilePanelFileName = { fg = colors.fg },
			DiffviewFilePanelSelected = { fg = (highlights.Type or {}).fg or colors.blue1 },
			DiffviewFilePanelPath = { fg = colors.comment },
			DiffviewFilePanelInsertions = { fg = colors.git.add },
			DiffviewFilePanelDeletions = { fg = colors.git.delete },
			DiffviewFilePanelConflicts = { fg = colors.warning },
			DiffviewFilePanelMarked = { fg = colors.info },
			-- the per-entry status letters, linked to `diffAdded`/`diffChanged`/`diffRemoved`
			DiffviewStatusAdded = { fg = colors.git.add },
			DiffviewStatusUntracked = { fg = colors.git.add },
			DiffviewStatusModified = { fg = colors.git.change },
			DiffviewStatusRenamed = { fg = colors.git.change },
			DiffviewStatusCopied = { fg = colors.git.change },
			DiffviewStatusTypeChange = { fg = colors.git.change },
			DiffviewStatusUnmerged = { fg = colors.git.change },
			DiffviewStatusUnknown = { fg = colors.git.delete },
			DiffviewStatusDeleted = { fg = colors.git.delete },
			DiffviewStatusBroken = { fg = colors.git.delete },
			DiffviewStatusIgnored = { fg = colors.comment },
		}

		for group, hl in pairs(panel) do
			hl.bg = colors.none
			highlights[group] = hl
		end
	end)
