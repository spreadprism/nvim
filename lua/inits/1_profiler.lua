-- $PROF=1 profiles startup: stops and opens the picker on UIEnter.
-- $PROF=2 profiles until <leader>=p: the stop "event" is a User pattern that
--         nothing ever fires, so tracing runs until the toggle stops it.
if vim.env.PROF then
	require("internal.loader.plugin.load").load("snacks")
	if vim.env.PROF == "2" then
		require("internal.profiler").startup({
			startup = { event = "User", pattern = "ProfilerManualStop" },
		})
	else
		require("internal.profiler").startup()
	end
end
