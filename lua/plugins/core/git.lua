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
	:cmd("Neogit")
	:keymaps({
		k:group("git", "<leader>g", {
			k:map("n", "b", k:cmd("Neogit branch"), "branch"),
			k:map("n", "l", k:cmd("Neogit log"), "log"),
			k:map("n", "p", k:cmd("Neogit pull"), "pull"),
			k:map("n", "P", k:cmd("Neogit push"), "push"),
			k:map("n", "c", k:cmd("Neogit commit"), "commit"),
			k:map("n", "g", function()
				vim.cmd("tablast")
				local ft = vim.bo.filetype

				local path
				if ft == "oil" then
					path = require("oil").get_current_dir()
				elseif ft == "fyler" then
					path = require("fyler.views.finder").instance().files.root_path
				else
					path = "%:p:h"
				end

				local git_dirs = vim.fs.find(".git", { upward = true, path = path })
				local cwd
				if git_dirs and git_dirs[1] then
					cwd = vim.fs.dirname(git_dirs[1])
				else
					cwd = vim.fn.getcwd()
				end
				require("neogit").open({
					cwd = cwd,
				})
			end, "Neogit"),
		}),
	})
	:after(function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "NeogitStatus",
			callback = function(args)
				-- Resolve the git dir for the repo this status buffer belongs to.
				local buf_path = vim.api.nvim_buf_get_name(args.buf)
				local search_path = buf_path ~= "" and vim.fs.dirname(buf_path) or vim.fn.getcwd()

				local git_dirs = vim.fs.find(".git", { upward = true, path = search_path })
				if not (git_dirs and git_dirs[1]) then
					return
				end

				local repo_root = vim.fs.dirname(git_dirs[1])

				-- Look for an executable pre-commit hook in the repo.
				local hook = vim.fs.joinpath(git_dirs[1], "hooks", "pre-commit")
				if vim.fn.executable(hook) ~= 1 then
					return
				end

				local overseer = require("overseer")
				local task = overseer.new_task({
					name = "pre-commit",
					cmd = { hook },
					cwd = repo_root,
				})

				task:subscribe("on_complete", function()
					vim.defer_fn(function()
						task:dispose()
					end, 5000)
					return false
				end)
				task:start()
			end,
		})
	end)

plugin("gitsigns"):cmd("Gitsigns"):event("BufEnter"):opts({
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
									vim.cmd(":CodeDiff history " .. hash .. "^.." .. hash)
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
