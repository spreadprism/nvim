-- Init for the scenario specs: loads the *real* config, not a stub.
--
-- The nixCats wrapper has already put the nix pack dir on 'packpath' and the
-- built config dir on 'runtimepath' (`--cmd source …/nvim-setup.lua`). We
-- prepend the working tree so `inits/*` and `lua/**` resolve to the checkout,
-- then run the config's own `init.lua`.
--
-- Headless nvim never fires `UIEnter`, and lze defers most of this config to
-- `User DeferredUIEnter`, so specs must call `scenario.boot()` to flush it.

local cwd = vim.uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:append(cwd .. "/after")

package.path = table.concat({
	cwd .. "/tests/?.lua",
	cwd .. "/tests/?/init.lua",
	package.path,
}, ";")

vim.o.swapfile = false
vim.o.shadafile = "NONE"
vim.o.more = false

-- the config itself (inits/*.lua: options, nixCats, internal globals, plugins)
dofile(cwd .. "/init.lua")

if not pcall(require, "plenary.busted") then
	local dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", dir })
	end
	vim.opt.rtp:append(dir)
	vim.cmd("runtime plugin/plenary.vim")
	require("plenary.busted")
end
