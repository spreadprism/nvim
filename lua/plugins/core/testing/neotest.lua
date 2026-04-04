plugin("neotest")
	:dep_on("overseer")
	:cmd("Neotest")
	:opts(function()
		local adapters = require("internal.loader.neotest").adapters()
		table.insert(adapters, require("rustaceanvim.neotest"))
		return {
			adapters = adapters,
			consumers = {
				---@diagnostic disable-next-line: assign-type-mismatch
				overseer = require("neotest.consumers.overseer"),
			},
			discovery = {
				enabled = false,
			},
			summary = {
				mappings = {
					expand = { "<tab>" },
					jumpto = "<CR>",
				},
			},
		}
	end)
	:keymaps({
		k:map("n", "<leader>dt", k:require("neotest").run.run({ strategy = "dap" }), "dap test"),
		k:group("unit-testing", "<leader>u", {
			k:map("n", "e", k:cmd("Neotest summary"), "tests explorer"),
			k:map("n", "c", k:cmd("lua require('neotest').run.run()"), "test current function"),
			k:map("n", "f", k:cmd("lua require('neotest').run.run(vim.fn.expand('%'))"), "test current file"),
			k:map("n", "p", k:cmd("lua require('neotest').run.run(vim.fn.getcwd())"), "test current project"),
			k:map("n", "x", k:cmd("lua require('neotest').run.stop()"), "stop current test"),
		}),
	})
