if nixCats("workspace") then
	plugin("exrc")
		:event_defer()
		:set_g_options({
			workspace = {
				file_name = ".nvim.lua",
			},
		})
		:opts({
			on_vim_enter = false,
			min_log_level = vim.log.levels.INFO,
		})
		:setup(function()
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				pattern = { "*/" .. vim.g.workspace.file_name },
				callback = function()
					vim.defer_fn(function()
						vim.cmd("ExrcReloadAll")
					end, 100)
				end,
			})
			require("exrc.loader").on_vim_enter()
		end)
end
