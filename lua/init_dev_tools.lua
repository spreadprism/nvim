local function toggle_profile()
	local prof = require("profile")
	if prof.is_recording() then
		prof.stop()
		vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
			if filename then
				prof.export(filename)
				vim.notify(string.format("Wrote %s", filename))
			end
		end)
	else
		prof.start("*")
	end
end

if nixCats("devtools") then
	require("profile").instrument_autocmds()
	local should_profile = os.getenv("NVIM_PROFILE")
	if should_profile and should_profile:lower():match("^start") then
		require("profile").start("*")
	else
		require("profile").instrument("*")
	end
	kmap("n", "<leader>=p", toggle_profile, "toggle profiling")
end

kgroup("<leader>=", "devtools", {}, {
	kmap("n", "s", kcmd("tab StartupTime"), "startup time"),
	kmap("n", "l", function()
		local state = require("lze").state(vim.fn.input("plugin name"))
		if state then
			vim.print("ready to be loaded")
		else
			if state == nil then
				vim.print("never loaded")
			else
				vim.print("loaded")
			end
		end
	end, "query plugin status"),
})
