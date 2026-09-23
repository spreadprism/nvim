--- `direnv export json` is a process spawn plus a full `setenv()` sweep, so
--- it must only run for writes that can actually change the environment.
--- A regression here is invisible (nothing breaks) and expensive (every
--- `:w` in every buffer pays for it), which is exactly the kind of thing
--- worth pinning down in a spec.

local direnv = require("internal.direnv")
local fixtures = require("helpers.fixtures")

describe("internal.direnv", function()
	local dir, reload, allow, reloads

	before_each(function()
		dir = fixtures.tmpdir()
		reloads = 0
		reload, allow = direnv.reload, direnv.allow
		direnv.reload = function()
			reloads = reloads + 1
		end
		direnv.allow = function() end
	end)

	after_each(function()
		direnv.reload, direnv.allow = reload, allow
		fixtures.cleanup()
	end)

	---@param relative string
	local function write_buffer(relative)
		local path = fixtures.write(dir, relative, { "# fixture" })
		fixtures.open(path)
		vim.cmd.write({ mods = { silent = true } })
	end

	it("reloads when the .envrc is written", function()
		write_buffer(".envrc")
		assert.are.equal(1, reloads)
	end)

	it("reloads when a dotenv file is written", function()
		write_buffer(".env")
		assert.are.equal(1, reloads)

		write_buffer(".env.local")
		assert.are.equal(2, reloads)
	end)

	it("stays quiet for every other write", function()
		write_buffer("src/main.go")
		write_buffer("README.md")
		write_buffer("envrc.lua")
		write_buffer("dot.env.backup.txt")

		assert.are.equal(0, reloads)
	end)
end)
