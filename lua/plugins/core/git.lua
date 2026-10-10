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

plugin("atlas")
	:opts(function()
		--- run one of atlas' own issue actions with the context the keymap was
		--- invoked with; works from the list *and* the detail panel, since both
		--- feed `keymaps.issues.custom` their own `(context, done)`
		---@param id AtlasIssueActionId|string
		local function action(id)
			return function(ctx, done)
				require("atlas.issues.actions").run(id, ctx, done)
			end
		end

		--- atlas has no priority action: the field is fetched and rendered but
		--- never written (`edit_issue` only sends summary/description/type/
		--- assignee), so drive the jira REST api directly through its client,
		--- which already carries the configured auth
		---@param ctx AtlasIssueActionContext
		---@param done fun(result: table|nil, err: string|nil)
		local function change_priority(ctx, done)
			local issue = ctx and ctx.issue
			if not issue or not issue.key then
				return done(nil, "No issue selected")
			end

			local key = issue.key
			local client = require("atlas.providers.jira.client")
			local notify = require("atlas.core.notify")

			-- `editmeta` returns the values this issue's screen actually allows,
			-- unlike the instance-wide `/priority` list
			client.request("GET", string.format("/issue/%s/editmeta", key), nil, function(meta, err)
				if err then
					return done(nil, err)
				end

				local field = ((meta or {}).fields or {}).priority
				local options = field and field.allowedValues or {}
				if #options == 0 then
					return done(nil, string.format("%s has no editable priority", key))
				end

				require("atlas.ui.picker").select({
					title = string.format("Priority for %s", key),
					items = options,
					format_item = function(item)
						return tostring(item.name or item.id)
					end,
					on_select = function(choice)
						if not choice then
							-- cancelled: no result, no error
							return done(nil, nil)
						end

						notify.loading(string.format("Updating %s...", key))
						require("atlas.issues.providers.jira.api.issues").update_issue(
							key,
							{ priority = { id = choice.id } },
							function(ok, update_err)
								if not ok then
									local message = update_err or "Failed to set priority"
									notify.error(message)
									return done(nil, message)
								end

								notify.success(
									string.format("%s → %s", key, choice.name or choice.id),
									{ timeout = 1200 }
								)
								-- `issue_key` makes the dashboard/panel reload that row
								done({ issue_key = key }, nil)
							end
						)
					end,
				})
			end, { action = "Fetch priority options", issue_key = key })
		end

		---@type AtlasConfig
		return {
			ui = {
				-- key hints, loading progress and notifications all render here;
				-- atlas forces `laststatus = 3` while it is enabled
				statusline = true,
				picker = "snacks",
			},
			providers = {
				github = {
					hostname = vim.env.GH_HOST or "github.com",
				},
				jira = {
					base_url = vim.env.JIRA_BASE_URL,
					email = vim.env.JIRA_EMAIL,
					token = vim.env.JIRA_API_TOKEN,
				},
			},
			pulls = {
				git_transport = "ssh",
				default_merge_method = "squash",
				diff = {
					-- any command taking explicit `<base>...<head>` revisions;
					-- the atlas overlays know about diffview
					open_cmd = "DiffviewOpen",
				},
			},
			issues = {
				---@type AtlasJiraIssuesConfig
				jira = {
					views = {
						{
							-- everything currently in focus: started, queued
							name = "Active",
							key = "1",
							layout = "plain",
							jql = table.concat({
								"assignee = currentUser()",
								'AND status in ("In Progress", Ready)',
								"ORDER BY statusCategory DESC, status DESC, updated DESC, key ASC",
							}, " "),
						},
						{
							-- the whole board, not just my rows
							name = "Team",
							key = "2",
							layout = "compact",
							jql = table.concat({
								'project = "Platform Engineering"',
								"ORDER BY resolution DESC, status ASC, Rank ASC",
							}, " "),
						},
					},
					-- the long tail: reachable from the `J` picker instead of
					-- spending a view key on each
					bookmarks = {
						items = {
							["Triage"] = table.concat({
								'project = "Platform Engineering"',
								"AND status in (IDEAS, Backlog)",
								"ORDER BY created DESC",
							}, " "),
							["Done"] = table.concat({
								"assignee = currentUser()",
								"AND statusCategory = Done",
								"AND statusCategory != Rejected",
								"ORDER BY resolved DESC, updated DESC",
							}, " "),
							["In QA"] = table.concat({
								'project = "Platform Engineering"',
								"AND status = QA",
								"ORDER BY Rank ASC",
							}, " "),
						},
					},
				},
			},
			-- atlas merges this over its defaults, so every action is spelled out
			-- to keep the whole surface in one place.
			--
			-- the house style, same as neogit:
			--   * a bare letter for anything done constantly (never one that is a
			--     motion: `w`, `b`, `h`, `l`, `H`, `L`, `n`, `N`, ...)
			--   * `<localleader>` + letter for the verbs that act, submit or edit
			--   * `g` + letter only when the first two are exhausted
			--
			-- `:checkhealth atlas` reports keys bound twice *per scope* (`ui`,
			-- `ui`+`pulls`, `ui`+`issues`, `picker`, notifications on their own).
			-- the few keys shared below sit in atlas' own allow-list, except `-`,
			-- which is deliberately "toggle the side panel" everywhere.
			---@type AtlasKeymapsConfig
			keymaps = {
				-- every atlas buffer: the list, the detail tabs, the panels
				ui = {
					-- motion
					next_item = { "j", "<Down>" },
					previous_item = { "k", "<Up>" },
					first_item = "gg",
					last_item = "G",
					next_panel_tab = "<Right>",
					previous_panel_tab = "<Left>",
					-- `]p`/`[p` by default; paging is rare enough for the `g` tier
					next_page = "gn",
					previous_page = "gp",
					-- open / close
					select = "<CR>",
					submit = "<C-s>",
					close = "<C-q>",
					help = "<localleader>?",
					toggle_panel = "-",
					toggle_fold = "za",
					toggle_all_folds = "zA",
					-- the action menu is the catch-all for everything not bound here
					open_actions = "A",
					show_details = "K",
					search = "f",
					-- same letter as neogit's `commit_view` browser mapping
					open_in_browser = "o",
					-- linked issues/PRs: `l` is a motion, so `g` tier
					open_references = "gl",
					-- comments
					comments = {
						add = "a",
						reply = "c",
						edit = "e",
						react = "<localleader>e",
					},
					delete = "D",
					-- state
					refresh = "r",
					refresh_view = "R",
					-- `s` belongs to the status transition, so starring keeps the
					-- glyph atlas uses in the list
					toggle_star = "*",
					toggle_subscription = "S",
					copy_id = "y",
					copy_url = "Y",
					-- the notification panel is its own scope: `r`/`d` here never
					-- meet `ui.refresh`/`pulls.open_diff`
					notifications = {
						open = "N",
						mark_read = "r",
						mark_done = "d",
					},
				},
				-- only used by the builtin picker; `ui.picker = "snacks"` bypasses it
				picker = {
					next_item = { "<Down>", "<C-n>", "<C-j>" },
					previous_item = { "<Up>", "<C-p>", "<C-k>" },
					select = { "<CR>", "<C-s>" },
					toggle = "<Tab>",
					close = { "<C-q>", "<Esc>" },
				},
				issues = {
					-- `ui.select` only runs bookmarks in the issue list, and the
					-- general `ui.toggle_panel` map is registered *before* it, so
					-- adding `<CR>` there would be clobbered. custom maps are the
					-- last ones registered on the dashboard, so this one wins.
					custom = {
						{
							key = "<CR>",
							desc = "Open issue details",
							callback = function()
								local node = require("atlas.ui.navigation").current_item()

								-- bookmark and starred rows keep the `ui.select` behaviour
								if type(node) == "table" and (node.kind == "bookmark" or node.kind == "starred") then
									return require("atlas.issues.ui.dashboard.controller").select_bookmark(node)
								end

								local dashboard = require("atlas.issues.ui.dashboard")
								if require("atlas.issues.ui.detail").is_open() then
									-- `toggle_detail` would close it; re-target it instead,
									-- `select` keeps the dashboard's `on_update` wiring
									dashboard.select(node)
								else
									dashboard.toggle_detail()
								end

								-- the panel opens next to the dashboard without taking the
								-- cursor; `-` keeps it that way, `<CR>` jumps into it.
								-- the window id only lives on the detail state
								vim.schedule(function()
									local win = require("atlas.issues.ui.detail.state").win
									if win and vim.api.nvim_win_is_valid(win) then
										vim.api.nvim_set_current_win(win)
									end
								end)
							end,
						},
						-- the builtin `transition_issue`/`change_assignee`/
						-- `change_reporter` maps only exist in the list; the detail
						-- panel registers `ui.*` plus these custom entries, so routing
						-- them through `custom` is what makes them work in both
						{ key = "s", desc = "Transition issue", callback = action("transition") },
						{ key = "<localleader>a", desc = "Change assignee", callback = action("assign") },
						{ key = "<localleader>r", desc = "Change reporter", callback = action("reporter") },
						{ key = "<localleader>p", desc = "Change priority", callback = change_priority },
					},
					-- superseded by the `custom` entries above, which also reach the
					-- detail panel
					transition_issue = false,
					change_assignee = false,
					change_reporter = false,
					-- `c` is also `ui.comments.reply`: both "write something new"
					create_issue = "c",
					-- `e` edits a *comment*, `E` the issue itself
					edit_issue = "E",
					-- drops straight into insert mode on the jql line
					edit_search = "i",
					toggle_description_mode = "<localleader>m",
				},
				pulls = {
					open_diff = "d",
					-- `t` is also `review.diff.toggle_layout`, never on screen together
					toggle_repo_issue_state = "t",
					-- `T` is also `review.explorer.toggle_grouping`
					edit_title = "T",
					edit_search = "i",
					edit_description = "<localleader>d",
					open_repository = "<localleader>o",
					-- the atlas cheatsheet while inside diffview, where `<localleader>?`
					-- already belongs to diffview's own help
					external_help = "<localleader>h",
					-- `c` and `d` are taken, and checkout is a once-per-PR action
					checkout = "gc",
					-- state filters, grouped like neogit's popups
					filters = {
						open = "<localleader>fo",
						merged = "<localleader>fm",
						declined = "<localleader>fd",
					},
					pipelines = {
						-- same keys as the file explorer's file-to-file motion
						next_job = "<Tab>",
						previous_job = "<S-Tab>",
						show_history = "gh",
						toggle_raw_logs = "gL",
						toggle_auto_refresh = "gr",
					},
					review = {
						open_item = "<CR>",
						show_details = "K",
						-- the verdict: everything that posts to the provider
						approve = "<localleader>a",
						request_changes = "<localleader>r",
						submit_review = "<localleader>v",
						add_task = "<localleader>t",
						comment_templates = "<localleader>c",
						find_file = "<localleader>ff",
						explorer = {
							-- `-` toggles the side panel everywhere in atlas and diffview
							toggle_explorer = "-",
							find_file = "<localleader>ff",
							next_file = "<Tab>",
							previous_file = "<S-Tab>",
							next_unreviewed_file = "gu",
							previous_unreviewed_file = "gU",
							toggle_grouping = "T",
							-- mark the file as reviewed
							toggle_file_reviewed = "m",
							toggle_commits = "gC",
						},
						diff = {
							-- write: lowercase adds, uppercase submits
							add_comment = "c",
							submit_comment = "C",
							add_suggestion = "<localleader>s",
							submit_suggestion = "<localleader>S",
							-- local note, never posted to the provider
							add_note = "<localleader>n",
							toggle_resolved = "x",
							-- motion between annotations, same bracket pairs as the
							-- `]x`/`[x` conflict walk in diffview
							next_hunk = "]h",
							previous_hunk = "[h",
							next_comment = "]c",
							previous_comment = "[c",
							next_note = "]n",
							previous_note = "[n",
							-- layout toggles
							toggle_layout = "t",
							toggle_compact = "gc",
							toggle_comments = "gh",
							toggle_review_panel = "gr",
							toggle_detail_panel = "gd",
						},
					},
				},
			},
		}
	end)
	:event("DeferredUIEnter")
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "i", function()
				if vim.env.JIRA_BASE_URL then
					vim.cmd("Atlas issues jira")
				else
					vim.cmd("Atlas issues github")
				end
			end, "issues"),
			k:map("n", "p", k:cmd("Atlas pipelines ."), "pipelines"),
			k:map("n", "r", k:cmd("Atlas review"), "review PR"),
			k:map("n", "P", k:cmd("Atlas create pr"), "create PR"),
			k:map("n", "I", k:cmd("Atlas create issue"), "create issue"),
			k:map("n", "b", k:cmd("Atlas browse ."), "browse repo"),
		}),
	})

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
		graph_style = "kitty",
		prompt_amend_commit = false,
		use_default_keymaps = false,
		mappings = {
			commit_editor = {
				["<C-q>"] = "Close",
				["<C-a>"] = "Abort",
				["<C-s>"] = "Submit",
				["<Up>"] = "PrevMessage",
				["<Down>"] = "NextMessage",
			},
			commit_editor_I = {
				["<C-s>"] = "Submit",
				["<C-a>"] = "Abort",
			},
			-- `use_default_keymaps = false` resets `mappings` to a fixed set of
			-- sections that omits these, and the modules reading them index the
			-- missing table at load time, so they must be declared explicitly
			commit_view = {
				["a"] = "OpenFileInWorktree",
				["o"] = "OpenCommitLinkInBrowser",
			},
			refs_view = {
				["x"] = "DeleteBranch",
			},
			rebase_editor = {
				["p"] = "Pick",
				["r"] = "Reword",
				["e"] = "Edit",
				["s"] = "Squash",
				["f"] = "Fixup",
				["x"] = "Execute",
				["d"] = "Drop",
				["b"] = "Break",
				["q"] = "Close",
				["<cr>"] = "OpenCommit",
				["gk"] = "MoveUp",
				["gj"] = "MoveDown",
				["<c-c><c-c>"] = "Submit",
				["<C-a>"] = "Abort",
			},
			rebase_editor_I = {
				["<c-c><c-c>"] = "Submit",
				["<C-a>"] = "Abort",
			},
			status = {
				["!"] = "Command",
				["^"] = "CommandHistory",
				["j"] = "MoveDown",
				["k"] = "MoveUp",
				["<C-q>"] = "Close",
				["I"] = "InitRepo",
				["<tab>"] = "Toggle",
				["D"] = "Discard",
				["s"] = "Stage",
				["<M-s>"] = "StageUnstaged",
				["S"] = "StageAll",
				["u"] = "Unstage",
				["U"] = "UnstageStaged",
				["t"] = "Untrack",
				["K"] = "PeekFile",
				["<c-r>"] = "RefreshBuffer",
				-- a function value makes this a neogit *user mapping*, which replaces
				-- the built-in `VSplitOpen`: files keep the vsplit behaviour, but the
				-- recent/unmerged/unpulled commit sections open the commit view
				["<cr>"] = function()
					local status = require("neogit.buffers.status").instance()
					if not status then
						return
					end

					local ui = status.buffer.ui

					local item = ui:get_item_under_cursor()
					if item and item.absolute_path then
						return require("neogit.buffers.status.actions").n_vertical_split_open(status)()
					end

					-- `oid` is only set on commit components
					local oid = ui:get_commit_under_cursor()
					if oid then
						require("internal.git").commit(oid, { kind = "tab" })
					end
				end,
				["<s-cr>"] = "TabOpen",
				["<Down>"] = "NextSection",
				["<Up>"] = "PreviousSection",
			},
			popup = {
				["?"] = "HelpPopup",
				["c"] = "CommitPopup",
				["gb"] = "BranchPopup",
				["gB"] = "BisectPopup",
				["gw"] = "WorktreePopup",
				["p"] = "PullPopup",
				["P"] = "PushPopup",
				["f"] = "FetchPopup",
				["r"] = "RebasePopup",
				["m"] = "MergePopup",
				["d"] = "DiffPopup",
				["R"] = "RemotePopup",
				["i"] = "IgnorePopup",
				["x"] = "RevertPopup",
				["X"] = "ResetPopup",
				["T"] = "TagPopup",
				["gl"] = "LogPopup",
				["gs"] = "StashPopup",
				["gc"] = "CherryPickPopup",
			},
		},
	})
	:cmd("Neogit")
	:keymaps(function()
		--- open a neogit popup from anywhere, without going through the status
		--- buffer: `neogit.popups.open` returns a curried opener.
		--- its default wrapper calls `create()` with no argument, but most popups
		--- index `env` unconditionally (`env.commit`, `env.item`, `env.hunk`, ...),
		--- so pass an empty env: every field they read may legitimately be nil
		---@param name string module name under `neogit.popups`
		local function popup(name)
			return function()
				require("neogit.popups").open(name, function(create)
					create({})
				end)()
			end
		end

		--- `init_repo` prompts for a directory, so it has to run in an async
		--- context like the status buffer's own `InitRepo` action does
		local function init_repo()
			require("neogit.lib.async").void(function()
				require("neogit.lib.git").init.init_repo()
			end)()
		end

		return {
			k:group("git", "<leader>g", {
				k:map("n", "g", function()
					vim.cmd("tablast")
					local path = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand("%:p:h")
					require("neogit").open({ cwd = vim.fs.root(path ~= "" and path or vim.fn.getcwd(), ".git") })
				end, "Neogit"),
				-- same letters as the `popup` mappings inside the status buffer
				k:group("popups", "<localleader>", {
					k:map("n", "I", init_repo, "init repo"),
					k:map("n", "c", popup("commit"), "commit"),
					k:map("n", "gb", popup("branch"), "branch"),
					k:map("n", "p", popup("pull"), "pull"),
					k:map("n", "P", popup("push"), "push"),
					k:map("n", "f", popup("fetch"), "fetch"),
					k:map("n", "r", popup("rebase"), "rebase"),
					k:map("n", "m", popup("merge"), "merge"),
					k:map("n", "d", popup("diff"), "diff"),
					k:map("n", "R", popup("remote"), "remote"),
					k:map("n", "i", popup("ignore"), "gitignore"),
					k:map("n", "X", popup("reset"), "reset"),
					k:map("n", "gs", popup("stash"), "stash"),
					k:map("n", "gc", popup("cherry_pick"), "cherry pick"),
					k:map("n", "T", popup("tag"), "tag"),
					k:map("n", "gl", popup("log"), "log"),
					k:map("n", "x", popup("revert"), "revert"),
					k:map("n", "gB", popup("bisect"), "bisect"),
					k:map("n", "gw", popup("worktree"), "worktree"),
				}),
			}),
		}
	end)

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
									require("internal.git").commit(hash, { kind = "tab" })
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
			k:map("n", "w", k:require("worktrunk").pick(), "select worktree"),
			k:map("n", "W", function()
				local wt = require("worktrunk")
				wt.switch(wt.base().branch)
			end, "worktree (BASE)"),
			k:map("n", "c", k:require("worktrunk").create(), "create worktree"),
			k:map("n", "C", function()
				require("worktrunk").create(nil, require("worktrunk").base().branch)
			end, "create worktree (BASE)"),
			k:map("n", "m", k:require("worktrunk").merge({ no_remove = true }), "merge worktree"),
			k:map("n", "M", k:require("worktrunk").merge(), "merge worktree"),
			k:map("n", "x", k:require("worktrunk").delete(), "delete worktree"),
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
