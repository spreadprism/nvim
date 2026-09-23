--- One "real editing session" per filetype, profiled.
---
--- The shape is always the same: open a file, let everything the config hangs
--- off `BufReadPost`/`FileType` settle (LSP attach, treesitter, linters,
--- diagnostics), type a line, save, let the save-time machinery settle
--- (formatters, linters, LSP didSave), then undo the edit and save again.
---
--- Each phase is wall-clocked and the whole scenario runs with the snacks
--- profiler attached, so a slow filetype can be traced to the function that
--- made it slow instead of just "opening go files feels bad".
local profiler = require("internal.profiler")

local M = {}

--- Settle time after open and after write, in milliseconds. Async work (LSP
--- handshake, formatter subprocesses) only shows up if we wait for it.
M.WAIT_MS = tonumber(os.getenv("NVIM_FT_WAIT_MS") or "") or 2000

--- Traces kept per scenario in the final report.
M.TOP_TRACES = 5

--- Profiler config for the scenarios.
---
--- `filter_mod` is not tuning, it is a workaround: snacks' tracer collects
--- results with `{ pcall(fn, ...) }` and returns `select(2, unpack(ret))`, so
--- a traced function returning `nil, value` is truncated to `nil`. conform
--- (`err, lines`) and gitsigns (`stdout, stderr, code`) both use that shape
--- and *break* while traced — conform dies on every `:write`. Upstream keeps a
--- list like this for the same reason (`mason-core.functional`, ...).
---@type snacks.profiler.Config
M.PROFILER_OPTS = {
	on_stop = { highlights = false, pick = false },
	filter_mod = {
		["^conform%."] = false,
		["^gitsigns%."] = false,
	},
}

---@class Scenario.Phase
---@field open number ms spent in `:edit` itself
---@field settle_open number ms waited after opening
---@field write number ms spent in the first `:write`
---@field settle_write number ms waited after writing
---@field revert number ms spent undoing the edit and writing again
---@field total number ms for the whole scenario

---@class Scenario.Trace
---@field name string
---@field time number milliseconds
---@field count integer

---@class Scenario.Result
---@field label string
---@field filetype string detected filetype
---@field expected string filetype the spec asked for
---@field path string
---@field phases Scenario.Phase
---@field clients string[] LSP clients attached at the end of the open phase
---@field traces Scenario.Trace[] slowest profiler traces
---@field events integer raw profiler events captured
---@field error? string failure raised inside the scenario, if any

---@type Scenario.Result[]
M.results = {}

---@param fn fun()
---@return number ms
local function timed(fn)
	local started = vim.uv.hrtime()
	fn()
	return (vim.uv.hrtime() - started) / 1e6
end

--- Pump the event loop for `ms`, letting timers, jobs and scheduled callbacks
--- run. `vim.wait` with a never-true predicate is the blocking-but-fair way to
--- do that from a spec.
---@param ms integer
---@return number ms actually waited
local function settle(ms)
	return timed(function()
		vim.wait(ms, function()
			return false
		end, 20)
	end)
end
M.settle = settle

--- Flush the config's deferred loading. Headless nvim has no UI, so `UIEnter`
--- never fires and lze's `DeferredUIEnter` plugins would stay unloaded.
---@param ms? integer extra settle time
function M.boot(ms)
	vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
	vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
	settle(ms or 500)
end

--- Build a workspace on disk: the file under test plus whatever sibling files
--- its language server needs to recognise a project root.
---@param spec { file: string, lines: string[], extra?: table<string, string[]> }
---@return string dir
---@return string path
function M.workspace(spec)
	local dir = vim.fn.tempname()
	vim.fn.mkdir(vim.fs.joinpath(dir, ".git"), "p")

	for relative, lines in pairs(spec.extra or {}) do
		local path = vim.fs.joinpath(dir, relative)
		vim.fn.mkdir(vim.fs.dirname(path), "p")
		vim.fn.writefile(lines, path)
	end

	local path = vim.fs.joinpath(dir, spec.file)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(spec.lines, path)

	return dir, path
end

--- Slowest traces of the run, grouped by function name.
---@return Scenario.Trace[]
---@return integer events
local function collect_traces()
	local ok, traces = pcall(function()
		return Snacks.profiler.find({ group = "name", sort = "time", structure = false })
	end)
	local events = #(Snacks.profiler.core.events or {})
	if not ok or type(traces) ~= "table" then
		return {}, events
	end

	local top = {}
	for index = 1, math.min(M.TOP_TRACES, #traces) do
		local trace = traces[index]
		top[index] = {
			name = trace.name or "?",
			time = (trace.time or 0) / 1e6,
			count = trace.count or 1,
		}
	end
	return top, events
end

--- Open, edit, save, revert — with the profiler running.
---@param spec { label: string, filetype: string, file: string, lines: string[], insert: string, extra?: table<string, string[]> }
---@return Scenario.Result
function M.run(spec)
	local dir, path = M.workspace(spec)
	local wait = M.WAIT_MS

	-- a scenario that threw before its `stop()` leaves the profiler running
	if Snacks.profiler.running() then
		profiler.stop({ highlights = false, pick = false })
	end
	profiler.start(M.PROFILER_OPTS)

	local phases = {}
	local detected, clients
	local ok, err

	phases.total = timed(function()
		ok, err = pcall(function()
			phases.open = timed(function()
				vim.cmd.edit({ args = { path }, mods = { silent = true } })
			end)
			phases.settle_open = settle(wait)

			local buf = vim.api.nvim_get_current_buf()
			detected = vim.bo[buf].filetype
			clients = vim.tbl_map(function(client)
				return client.name
			end, vim.lsp.get_clients({ bufnr = buf }))

			local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

			phases.write = timed(function()
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { spec.insert })
				vim.cmd.write({ mods = { silent = true } })
			end)
			phases.settle_write = settle(wait)

			phases.revert = timed(function()
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, original)
				vim.cmd.write({ mods = { silent = true } })
			end)
		end)
	end)

	profiler.stop({ highlights = false, pick = false })
	settle(100) -- stop() schedules the trace load

	local traces, events = collect_traces()

	---@type Scenario.Result
	local result = {
		label = spec.label,
		filetype = detected or "",
		expected = spec.filetype,
		path = path,
		phases = phases,
		clients = clients or {},
		traces = traces,
		events = events,
		error = not ok and tostring(err) or nil,
	}
	M.results[#M.results + 1] = result

	-- leave nothing behind: servers for this workspace, the buffer, the files
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.root_dir and vim.startswith(vim.fs.normalize(client.root_dir), vim.fs.normalize(dir)) then
			client:stop(true)
		end
	end
	vim.cmd.enew({ mods = { silent = true } })
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.startswith(vim.api.nvim_buf_get_name(buf), dir) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
	vim.fn.delete(dir, "rf")

	return result
end

---@param result Scenario.Result
---@param emit fun(line: string)
local function report_one(result, emit)
	local phases = result.phases
	emit(
		string.format(
			"  %-14s ft=%-16s open %7.1fms  write %7.1fms  revert %7.1fms  lsp=%s",
			result.label,
			result.filetype ~= "" and result.filetype or "-",
			phases.open or 0,
			phases.write or 0,
			phases.revert or 0,
			#result.clients > 0 and table.concat(result.clients, ",") or "-"
		)
	)
	if result.error then
		emit(string.format("    ! %s", vim.split(result.error, "\n")[1]))
	end
end

--- The summary, printed once after every scenario has run and — when
--- `$NVIM_FT_REPORT` is set — written there verbatim. The file is only
--- replaced once the run reaches this point, so a crashed run leaves the
--- previous report intact.
---@return string[] lines
function M.report()
	local lines = {}
	local function emit(line)
		lines[#lines + 1] = line
		print(line)
	end

	emit("")
	emit("=== filetype scenarios ===========================================")
	emit(string.format("settle time: %dms after open and after write", M.WAIT_MS))
	emit("")

	local slowest_open, slowest_write = 0, 0
	for _, result in ipairs(M.results) do
		report_one(result, emit)
		slowest_open = math.max(slowest_open, result.phases.open or 0)
		slowest_write = math.max(slowest_write, result.phases.write or 0)
	end

	emit("")
	emit("--- slowest traces per scenario (profiler) -----------------------")
	for _, result in ipairs(M.results) do
		emit(string.format("  %s (%d events)", result.label, result.events))
		if #result.traces == 0 then
			emit("    (no traces captured)")
		end
		for _, trace in ipairs(result.traces) do
			emit(string.format("    %8.2fms  x%-5d %s", trace.time, trace.count, trace.name))
		end
	end

	emit("")
	emit(
		string.format(
			"scenarios: %d   slowest open: %.1fms   slowest write: %.1fms",
			#M.results,
			slowest_open,
			slowest_write
		)
	)
	emit("==================================================================")

	local path = os.getenv("NVIM_FT_REPORT")
	if path and path ~= "" then
		-- drop the leading blank line: it only separates the report from the
		-- busted output on the terminal
		local out = vim.list_slice(lines, 2, #lines)
		vim.fn.writefile(out, path)
		print(string.format("report written to %s", path))
	end

	return lines
end

return M
