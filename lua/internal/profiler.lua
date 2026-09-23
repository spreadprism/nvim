--- Single entry point for profiling.
---
--- Both the `$PROF` startup path (`inits/1_profiler.lua`) and the `<leader>=p`
--- toggle go through here, so profiler config/workarounds only need to live in
--- one place.
local M = {}

---@type snacks.profiler.Config
M.opts = {
	startup = {
		event = "UIEnter",
	},
}

--- HACK: nvim 0.13 moved core lua modules to `vim/_core/*`, and reports their
--- chunk name without the `.lua` suffix (`@vim/_core/shared`). When the
--- profiler stops it resolves definition locations with
--- `readfile(VIMRUNTIME .. "/lua/" .. file)` (snacks/profiler/loc.lua:91) and
--- dies with E484. Only affects location lookup, not the traces themselves.
local patched = false
local function patch_loc()
	if patched then
		return
	end
	patched = true

	local loc = require("snacks.profiler.loc")
	local ts_locs = loc.ts_locs
	---@param file string
	function loc.ts_locs(file)
		if vim.fn.filereadable(file) == 0 then
			if vim.fn.filereadable(file .. ".lua") == 0 then
				return {}
			end
			file = file .. ".lua"
		end
		return ts_locs(file)
	end
end

--- Start profiling right away, tracing everything until `startup.event` fires.
---@param opts? snacks.profiler.Config
function M.startup(opts)
	patch_loc()
	require("snacks.profiler").startup(vim.tbl_deep_extend("force", M.opts, opts or {}))
end

--- Start profiling, or stop and open the results picker.
function M.toggle()
	patch_loc()
	require("snacks.profiler").toggle()
end

--- Start profiling now (no startup event). Used by the scenario specs.
---@param opts? snacks.profiler.Config
function M.start(opts)
	patch_loc()
	require("snacks.profiler").start(opts)
end

--- Stop profiling. Pass `{ pick = false, highlights = false }` for a silent stop.
---@param opts? {highlights?:boolean, pick?:snacks.profiler.Pick.spec}
function M.stop(opts)
	require("snacks.profiler").stop(opts)
end

function M.running()
	return require("snacks.profiler").running()
end

return M
