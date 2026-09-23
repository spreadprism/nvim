--- Timing helpers for the performance specs.
---
--- Every measurement here is wall clock on the main loop, which is what the
--- editor actually feels: a keystroke handler that takes 20ms is 20ms of
--- frozen UI regardless of where the time went.
---
--- Numbers from a single call are noise. `measure()` warms up first (JIT,
--- caches, lazily required modules), then takes N samples and reports the
--- distribution. Assertions use the *median*, never the mean: one GC pause or
--- a scheduler hiccup must not fail a suite.
local M = {}

--- One frame at 60Hz. The reference for anything synchronous on the UI path.
M.FRAME_MS = 16

---@class Bench.Opts
---@field samples? integer measured runs (default 30)
---@field warmup? integer unmeasured runs before sampling (default 5)
---@field batch? integer calls per sample, for sub-microsecond work (default 1)
---@field gc? boolean collect garbage before each sample (default true)

---@class Bench.Result
---@field label string
---@field samples number[] per-call milliseconds, sorted
---@field median number
---@field mean number
---@field min number
---@field max number
---@field p95 number
---@field total number milliseconds spent in the measured runs

--- Wall clock of a single call, in milliseconds.
---@param fn fun()
---@return number ms
function M.time(fn)
	local started = vim.uv.hrtime()
	fn()
	return (vim.uv.hrtime() - started) / 1e6
end

---@param sorted number[]
---@param quantile number 0..1
---@return number
local function percentile(sorted, quantile)
	if #sorted == 0 then
		return 0
	end
	local index = math.max(1, math.ceil(quantile * #sorted))
	return sorted[math.min(index, #sorted)]
end

--- Run `fn` repeatedly and describe how long one call takes.
---
--- `fn` receives the 1-based iteration number, so a spec can vary its input
--- across runs (different buffers, different query strings, ...) instead of
--- measuring the same warm cache over and over.
---@param label string
---@param fn fun(iteration: integer)
---@param opts? Bench.Opts
---@return Bench.Result
function M.measure(label, fn, opts)
	opts = opts or {}
	local samples_n = opts.samples or 30
	local warmup_n = opts.warmup or 5
	local batch = opts.batch or 1
	local gc = opts.gc ~= false

	local iteration = 0
	local function run_batch()
		for _ = 1, batch do
			iteration = iteration + 1
			fn(iteration)
		end
	end

	for _ = 1, warmup_n do
		run_batch()
	end

	local samples, total = {}, 0
	for index = 1, samples_n do
		if gc then
			collectgarbage("collect")
		end
		local ms = M.time(run_batch) / batch
		samples[index] = ms
		total = total + ms
	end
	table.sort(samples)

	return {
		label = label,
		samples = samples,
		median = percentile(samples, 0.5),
		mean = total / samples_n,
		min = samples[1],
		max = samples[#samples],
		p95 = percentile(samples, 0.95),
		total = total,
	}
end

--- One line per measurement, so a run reads like a report even when green.
---@param result Bench.Result
---@return Bench.Result result unchanged, for chaining
function M.report(result)
	print(
		string.format(
			"  %-46s median %7.3fms  p95 %7.3fms  min %7.3fms  max %7.3fms",
			result.label,
			result.median,
			result.p95,
			result.min,
			result.max
		)
	)
	return result
end

--- Measure, print, and fail when the median blows the budget.
---
--- Budgets are deliberately generous: they catch "this got an order of
--- magnitude slower", not a 10% drift, because the machine running the suite
--- is never the machine the number was tuned on.
---@param label string
---@param budget_ms number
---@param fn fun(iteration: integer)
---@param opts? Bench.Opts
---@return Bench.Result
function M.budget(label, budget_ms, fn, opts)
	local result = M.report(M.measure(label, fn, opts))
	assert.is_true(
		result.median <= budget_ms,
		string.format("%s: %.3fms per call (budget %.3fms)", label, result.median, budget_ms)
	)
	return result
end

--- Assert that work does not get disproportionately slower as input grows.
---
--- Scaling is the property worth locking down: absolute milliseconds drift
--- with the machine, the ratio between a small and a large input does not.
---@param small Bench.Result
---@param large Bench.Result
---@param max_ratio number how many times slower `large` may be
function M.assert_scaling(small, large, max_ratio)
	local ratio = large.median / math.max(small.median, 0.001)
	print(string.format("  %-46s %.1fx slower than %s", large.label, ratio, small.label))
	assert.is_true(
		ratio <= max_ratio,
		string.format(
			"%s is %.1fx slower than %s (max %.1fx)",
			large.label,
			ratio,
			small.label,
			max_ratio
		)
	)
end

return M
