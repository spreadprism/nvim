if nixCats("testing") then
	plugin("neotest")
		:after(function()
			local adapters = {}
			if nixCats("go") then
				table.insert(adapters, require("neotest-golang")({}))
			end
			require("neotest").setup({
				adapters = adapters,
				summary = {
					mappings = {
						expand = { "<tab>" },
						jumpto = "<CR>",
					},
				},
			})
		end)
		:cmd("Neotest")
		:keys(kgroup("<leader>u", "unit-testing", {
			kmap("n", "e", kcmd("Neotest summary"), "tests explorer"),
			kmap("n", "c", kcmd("lua require('neotest').run.run()"), "test current function"),
			kmap("n", "f", kcmd("lua require('neotest').run.run(vim.fn.expand('%'))"), "test current file"),
			kmap("n", "p", kcmd("lua require('neotest').run.run(vim.fn.getcwd())"), "test current project"),
			kmap("n", "x", kcmd("lua require('neotest').run.stop()"), "stop current test"),
		}))
end
