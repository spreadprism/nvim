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
	-- no hooks: the `cd` worktrunk performs fires DirChanged, and
	-- `internal.workspace.switch` takes it from there (workspace registration,
	-- exrc/dap/lsp/direnv reload, buffer migration, UI refresh)
	:opts({})
