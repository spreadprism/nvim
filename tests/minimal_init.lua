-- Minimal init for running the test suite.
--
-- Run through the nixCats wrapper (`just test`) so the nix pack dir is on
-- 'packpath': plenary and lze live in its `start/` directory and are already
-- loaded by the time this file runs.
--
-- The working tree is *prepended* to 'runtimepath' so specs exercise the
-- checkout, not the built config in /nix/store.

local cwd = vim.uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:append(cwd .. "/after")

-- `require("helpers.bench")` and friends resolve inside tests/
package.path = table.concat({
	cwd .. "/tests/?.lua",
	cwd .. "/tests/?/init.lua",
	package.path,
}, ";")

-- nixCats: real plugin when launched through the wrapper, mock otherwise
require("nixCats.nixcats").setup({ non_nix_value = true })
_G.nixcats = require("nixCats")
_G.nixCats = _G.nixCats or _G.nixcats

-- plenary ships in the nix pack dir; fall back to a clone for a bare nvim
if not pcall(require, "plenary.busted") then
	local dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", dir })
	end
	vim.opt.rtp:append(dir)
	vim.cmd("runtime plugin/plenary.vim")
	require("plenary.busted")
end

vim.o.swapfile = false
vim.o.shadafile = "NONE"
vim.o.more = false
