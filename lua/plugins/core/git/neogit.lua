plugin("neogit")
	:dep_on("diffview")
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
