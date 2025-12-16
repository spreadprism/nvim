local M = {}

function M.read_cfg()
	local modules = nixcats.cats.plugins_init

	local filtered = {}
	local hasInit = {}

	-- INFO: find all directories that have init.lua
	for _, v in ipairs(modules) do
		if v:match("%.init$") then
			local parent = v:match("^(.+)%.init$")
			hasInit[parent] = true
		end
	end

	-- INFO: filter out files from directories with init.lua, and replace module.init with module
	for _, v in ipairs(modules) do
		if v:match("%.init$") then
			-- Replace "plugins.testDir.init" with "plugins.testDir"
			local parent = v:match("^(.+)%.init$")
			table.insert(filtered, parent)
		else
			-- Check if this file is in a directory that has init.lua
			local shouldSkip = false
			for parentWithInit, _ in pairs(hasInit) do
				-- If v starts with "parentWithInit." then it's a sibling of init.lua
				if v:match("^" .. parentWithInit:gsub("%.", "%%.") .. "%.") then
					shouldSkip = true
					break
				end
			end
			if not shouldSkip then
				table.insert(filtered, v)
			end
		end
	end
	modules = filtered

	-- INFO: sort by number of `.` then alphabetical
	table.sort(modules, function(a, b)
		local aDots = #vim.split(a, "%.")
		local bDots = #vim.split(b, "%.")
		if aDots == bDots then
			return a < b
		else
			return aDots < bDots
		end
	end)

	-- INFO: load snacks before anything else
	require("plugins.core.snacks")

	for _, module in ipairs(modules) do
		require(module)
	end
end

function M.load_cfg()
	require("lze").h.merge.trigger()
end

return M
