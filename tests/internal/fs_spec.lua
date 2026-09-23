local fs = require("internal.fs")
local fixtures = require("helpers.fixtures")

describe("internal.fs.find_up", function()
	local dir

	before_each(function()
		dir = fixtures.tmpdir()
	end)

	after_each(fixtures.cleanup)

	it("finds a marker in an ancestor directory", function()
		local marker = fixtures.write(dir, ".nvim.lua", { "-- workspace" })
		fixtures.write(dir, "a/b/c/file.lua", {})

		local found = fs.find_up(".nvim.lua", { path = vim.fs.joinpath(dir, "a/b/c") })

		assert.are.equal(vim.fs.normalize(marker), vim.fs.normalize(found or ""))
	end)

	it("returns nil when nothing matches below the stop directory", function()
		fixtures.write(dir, "a/b/file.lua", {})

		local found = fs.find_up("never-exists.toml", {
			path = vim.fs.joinpath(dir, "a/b"),
			stop = dir,
		})

		assert.is_nil(found)
	end)

	it("honours the type filter", function()
		fixtures.write(dir, "target/keep.txt", {})
		fixtures.write(dir, "a/file.lua", {})

		local as_dir = fs.find_up("target", { path = vim.fs.joinpath(dir, "a"), type = "directory" })
		local as_file = fs.find_up("target", { path = vim.fs.joinpath(dir, "a"), type = "file" })

		assert.are.equal(vim.fs.normalize(vim.fs.joinpath(dir, "target")), vim.fs.normalize(as_dir or ""))
		assert.is_nil(as_file)
	end)

	it("creates the file in the start directory when asked to", function()
		local start = vim.fs.joinpath(dir, "a/b")
		vim.fn.mkdir(start, "p")

		local created = fs.find_up(".nvim.lua", { path = start, stop = dir, create = true })

		assert.are.equal(vim.fs.normalize(vim.fs.joinpath(start, ".nvim.lua")), vim.fs.normalize(created or ""))
		assert.are.equal(1, vim.fn.filereadable(created))
	end)

	it("creates in create_path when one is given", function()
		local start = vim.fs.joinpath(dir, "a/b")
		vim.fn.mkdir(start, "p")

		local created = fs.find_up(".nvim.lua", {
			path = start,
			stop = dir,
			create = true,
			create_path = dir,
		})

		assert.are.equal(vim.fs.normalize(vim.fs.joinpath(dir, ".nvim.lua")), vim.fs.normalize(created or ""))
	end)

	it("defaults the start directory to the current buffer", function()
		local file = fixtures.write(dir, "a/b/file.lua", {})
		local marker = fixtures.write(dir, "a/.nvim.lua", {})
		fixtures.open(file)

		local found = fs.find_up(".nvim.lua")

		assert.are.equal(vim.fs.normalize(marker), vim.fs.normalize(found or ""))
	end)
end)
