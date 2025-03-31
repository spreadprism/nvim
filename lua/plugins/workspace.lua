if nixCats("workspace") then
	plugin("exrc"):triggerUIEnter():after(function()
		local workspace_file_name = ".nvim.lua"
		require("exrc").setup({
			on_vim_enter = false,
		})
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*/" .. workspace_file_name },
			callback = function()
				vim.defer_fn(function()
					vim.cmd("ExrcReloadAll")
				end, 100)
			end,
		})
		require("exrc.loader").on_vim_enter()
	end)
end
