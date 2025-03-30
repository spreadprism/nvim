if nixCats("testing") then
	plugin("neotest")
		:after(function()
			local adapters = {}
			if nixCats("go") then
				table.insert(adapters, require("neotest-golang")({}))
			end
			if nixCats("rust") then
				table.insert(adapters, require("neotest-rust"))
			end
			if nixCats("python") then
				table.insert(adapters, require("neotest-python")({}))
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
		:on_plugin({
			"neotest-golang",
			"neotest-rust",
			"neotest-python",
		})
		:cmd("Neotest")
		:keys(keymapGroup("<leader>u", "unit-testing", {
			keymap("n", "e", keymapCmd("Neotest summary"), "tests explorer"),
			keymap("n", "c", keymapCmd("lua require('neotest').run.run()"), "test current function"),
			keymap("n", "f", keymapCmd("lua require('neotest').run.run(vim.fn.expand('%'))"), "test current file"),
			keymap("n", "p", keymapCmd("lua require('neotest').run.run(vim.fn.getcwd())"), "test current project"),
			keymap("n", "x", keymapCmd("lua require('neotest').run.stop()"), "stop current test"),
		}))
end
