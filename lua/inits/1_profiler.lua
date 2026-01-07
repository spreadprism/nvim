if vim.env.PROF or vim.env.PROF == 1 then
	require("internal.loader.plugin.load").load("snacks")
	require("snacks.profiler").startup({
		startup = {
			event = "UIEnter",
		},
	})
end
