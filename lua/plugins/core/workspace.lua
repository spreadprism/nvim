plugin("exrc")
	:event("DeferredUIEnter")
	:before(function()
		vim.g.workspace_file_name = ".nvim.lua"
	end)
	:keymaps({
		k:map("n", "\\\\", function()
			local fname = vim.g.workspace_file_name
			local cwd = vim.fn.getcwd()

			-- Start from the current file's directory, or cwd for unnamed buffers.
			local start = vim.api.nvim_buf_get_name(0)
			if start == "" then
				start = cwd
			else
				start = vim.fs.dirname(start)
			end

			-- Walk up from the current file's directory looking for the
			-- workspace file, stopping once we reach the cwd.
			local found = vim.fs.find(fname, {
				upward = true,
				path = start,
				stop = vim.fs.dirname(cwd),
				type = "file",
			})[1]

			-- If none was found, create one in the cwd.
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
