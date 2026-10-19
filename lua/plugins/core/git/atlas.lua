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
						-- `<localleader>e` edits the *issue*, so reacting drops to the
						-- `g` tier
						react = "ge",
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
						{ key = "<localleader>e", desc = "Edit issue", callback = action("edit_issue") },
						{ key = "<localleader>p", desc = "Change priority", callback = change_priority },
					},
					-- superseded by the `custom` entries above, which also reach the
					-- detail panel
					transition_issue = false,
					change_assignee = false,
					change_reporter = false,
					-- `c` is also `ui.comments.reply`: both "write something new"
					create_issue = "c",
					-- superseded too: `<localleader>e` above reaches the panel
					edit_issue = false,
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
	:on_highlights(function(highlights, colors)
		-- `atlas/ui/shared/highlights.lua` hardcodes catppuccin hexes and applies
		-- them with `default = true`, re-running on `ColorScheme`; anything set
		-- here therefore wins permanently.
		-- the footer carries an explicit `bg` on every group, so each one has to
		-- be restated against the statusline background
		local bg = (highlights.StatusLine or {}).bg

		---@param fg string
		---@param bold? boolean
		local function footer(fg, bold)
			return { fg = fg, bg = bg, bold = bold }
		end

		local atlas = {
			-- the statusline atlas draws in its own buffers
			AtlasFooterBackground = { bg = bg },
			AtlasFooterText = footer(colors.comment),
			AtlasFooterActive = footer(colors.fg, true),
			AtlasFooterInfo = footer(colors.info, true),
			AtlasFooterNote = footer(colors.purple, true),
			AtlasFooterWarning = footer(colors.warning, true),
			AtlasFooterError = footer(colors.error, true),
			AtlasFooterSuccess = footer(colors.git.add, true),
			-- list and detail chrome, hardcoded upstream as well
			AtlasColumnHeader = { fg = colors.comment, bold = true },
			AtlasSectionHeader = { fg = colors.comment, bold = true, underline = true },
			AtlasTextMuted = { fg = colors.comment },
			AtlasTextMutedStrikethrough = { fg = colors.comment, strikethrough = true },
			AtlasTextNote = { fg = colors.purple, bold = true },
			AtlasTextWarning = { fg = colors.warning, bold = true },
			AtlasLogInfo = { fg = colors.info },
			AtlasLogCommand = { fg = colors.blue },
			AtlasLogGroup = { fg = colors.fg, bg = colors.bg_highlight, bold = true },
			-- chips invert, so they need a readable foreground against the accent
			AtlasChipActive = { fg = colors.bg, bg = colors.blue, bold = true },
			AtlasRelatedChip = { fg = colors.fg, bg = colors.bg_highlight, bold = true },
		}

		for group, hl in pairs(atlas) do
			highlights[group] = hl
		end
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
