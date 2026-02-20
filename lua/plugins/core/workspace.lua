plugin("exrc")
	:event("DeferredUIEnter")
	:before(function()
		vim.g.workspace_file_name = ".nvim.lua"
	end)
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
		require("exrc.loader").on_vim_enter()
	end)
