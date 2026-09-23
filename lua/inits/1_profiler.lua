if vim.env.PROF or vim.env.PROF == 1 then
	require("internal.loader.plugin.load").load("snacks")
	require("internal.profiler").startup()
end
