---Hashes neovim already trusts, keyed by sha256 (see `vim.secure`).
---@return table<string, true>
local function trusted_hashes()
	local fd = io.open(vim.fs.joinpath(vim.fn.stdpath("state") --[[@as string]], "trust"), "r")
	if not fd then
		return {}
	end

	local hashes = {}
	for line in fd:lines() do
		local hash = line:match("^(%S+)%s+")
		-- "!" marks a denied path, everything else is a sha256
		if hash and hash ~= "!" then
			hashes[hash] = true
		end
	end
	fd:close()

	return hashes
end

---A git worktree switch lands on a brand new path, so its workspace file is
---untrusted even though it is byte for byte one we already trusted elsewhere.
---Trust it for the new path so exrc can source it without prompting.
---@param dir string
local function trust_workspace_file(dir)
	local path = vim.fs.joinpath(dir, vim.g.workspace_file_name)

	local fd = io.open(path, "r")
	if not fd then
		return
	end
	local contents = fd:read("*a")
	fd:close()

	if not trusted_hashes()[vim.fn.sha256(contents)] then
		return
	end

	local ok, err = vim.secure.trust({ action = "allow", path = path })
	if not ok then
		vim.notify("could not trust " .. path .. ": " .. tostring(err), vim.log.levels.WARN)
	end
end

plugin("exrc")
	:event("DeferredUIEnter")
	:before(function()
		vim.g.workspace_file_name = ".nvim.lua"

		-- registered before exrc's own DirChanged handler so the file is already
		-- trusted by the time exrc tries to read it
		vim.api.nvim_create_autocmd("DirChanged", {
			group = vim.api.nvim_create_augroup("WorkspaceAutoTrust", { clear = true }),
			desc = "Trust an already known workspace file at its new path",
			callback = function(args)
				trust_workspace_file(args.file)
			end,
		})
	end)
	:keymaps({
		k:map("n", "<localleader><localleader>", function()
			local fname = vim.g.workspace_file_name
			local cwd = vim.fn.getcwd()

			-- Walk up from the current file's directory looking for the
			-- workspace file, stopping once we reach the cwd. If none was
			-- found, open (creating on save) one in the cwd.
			local found = fs.find_up(fname, {
				type = "file",
				stop = vim.fs.dirname(cwd),
			})

			vim.cmd.edit(found or vim.fs.joinpath(cwd, fname))
		end, "go to workspace file"),
	})
	:opts({
		on_vim_enter = false,
		on_dir_changed = {
			enabled = true,
			use_ui_select = false,
		},
		min_log_level = vim.log.levels.INFO,
	})
	:after(function()
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*/" .. vim.g.workspace_file_name },
			callback = function()
				vim.defer_fn(function()
					vim.cmd("ExrcReloadAll")
				end, 100)
			end,
		})
		_G.workspace = require("internal.workspace")
	end)
