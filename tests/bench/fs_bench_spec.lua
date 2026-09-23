--- Cost of the root-marker walk.
---
--- `fs.find_up` runs on the UI path: the `<localleader><localleader>`
--- workspace jump uses it, and the same upward walk shape is what LSP root
--- resolution does on every buffer open. It touches the filesystem once per
--- ancestor directory, so the thing to watch is depth, not project size.

local fs = require("internal.fs")
local bench = require("helpers.bench")
local fixtures = require("helpers.fixtures")

describe("internal.fs.find_up latency", function()
	local dir

	before_each(function()
		dir = fixtures.tmpdir()
	end)

	after_each(fixtures.cleanup)

	---@param depth integer
	---@return string deepest directory
	local function nested(depth)
		local path = dir
		for index = 1, depth do
			path = vim.fs.joinpath(path, "level" .. index)
		end
		vim.fn.mkdir(path, "p")
		return path
	end

	it("finds a nearby marker well inside a frame", function()
		fixtures.write(dir, ".nvim.lua", {})
		local start = nested(3)

		bench.budget("find_up hit at depth 3", 1, function()
			fs.find_up(".nvim.lua", { path = start, stop = dir })
		end)
	end)

	it("gives up on a missing marker without scanning the world", function()
		local start = nested(12)

		-- The miss is the expensive case: every ancestor up to `stop` is
		-- stat'd before the walk gives up.
		bench.budget("find_up miss at depth 12", 2, function()
			fs.find_up("never-exists.toml", { path = start, stop = dir })
		end)
	end)

	it("scales with depth, not with the number of files in the tree", function()
		fixtures.write(dir, ".nvim.lua", {})
		local start = nested(4)

		local small = bench.measure("find_up in a small tree", function()
			fs.find_up(".nvim.lua", { path = start, stop = dir })
		end)

		fixtures.tree(dir, 500)

		local large = bench.measure("find_up in a 500 file tree", function()
			fs.find_up(".nvim.lua", { path = start, stop = dir })
		end)

		bench.report(small)
		bench.report(large)
		-- Same ancestor chain, 500x the files: the walk must not notice.
		bench.assert_scaling(small, large, 3)
	end)
end)
