plugin("exrc")
	:event("DeferredUIEnter")
	:before(function()
		vim.g.workspace_file_name = ".nvim.lua"
	end)
	:keymaps({
		k:map("n", "<localleader><localleader>", function()
			local fname = vim.g.workspace_file_name
			local cwd = vim.fn.getcwd()

			-- Walk up from the current file's directory looking for the
			-- workspace file, stopping once we reach the cwd. If none was
			-- found, open (creating on save) one in the cwd.
			local found = fs.find_up(fname, {
				type = "file",
				stop = vim.fs.dirname(cwd),
			})

			vim.cmd.edit(found or vim.fs.joinpath(cwd, fname))
		end, "go to workspace file"),
	})
	:opts({
		on_vim_enter = false,
		min_log_level = vim.log.levels.INFO,
	})
	:after(function()
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*/" .. vim.g.workspace_file_name },
			callback = function()
				vim.defer_fn(function()
					vim.cmd("ExrcReloadAll")
				end, 100)
			end,
		})
		_G.workspace = require("internal.workspace")
	end)
