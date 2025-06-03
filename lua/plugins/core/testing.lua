if nixCats("core.testing") then
	plugin("neotest")
		:cmd("Neotest")
		:on_require("neotest")
		:dep_on("overseer")
		:config(function()
			require("neotest").setup({
				adapters = require("internal.neotest").list_adapters(),
				consumers = {
					---@diagnostic disable-next-line: assign-type-mismatch
					overseer = require("neotest.consumers.overseer"),
				},
				summary = {
					mappings = {
						expand = { "<tab>" },
						jumpto = "<CR>",
					},
				},
			})
		end)
		:keys({
			kgroup("<leader>u", "unit-testing", {}, {
				kmap("n", "e", kcmd("Neotest summary"), "tests explorer"),
				kmap("n", "c", kcmd("lua require('neotest').run.run()"), "test current function"),
				kmap("n", "f", kcmd("lua require('neotest').run.run(vim.fn.expand('%'))"), "test current file"),
				kmap("n", "p", kcmd("lua require('neotest').run.run(vim.fn.getcwd())"), "test current project"),
				kmap("n", "x", kcmd("lua require('neotest').run.stop()"), "stop current test"),
			}),
		})
end
