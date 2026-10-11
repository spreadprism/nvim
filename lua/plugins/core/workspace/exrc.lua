plugin("exrc")
	:event("DeferredUIEnter")
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
			enabled = false,
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
		-- DirChanged does not tell us where we came from, so remember it.
		local prev_cwd = vim.fs.normalize(vim.fn.getcwd(-1, -1))

		--- Path of `path` relative to `dir`, or nil when not inside it.
		---@param path string
		---@param dir string
		---@return string|nil
		local function relative(path, dir)
			if path == dir then
				return ""
			end
			local prefix = dir:gsub("/+$", "") .. "/"
			if path:sub(1, #prefix) == prefix then
				return path:sub(#prefix + 1)
			end
		end

		vim.api.nvim_create_autocmd("DirChanged", {
			callback = function(ev)
				if ev.match ~= "global" then
					return
				end

				local loader = require("exrc.loader")
				local old_cwd = prev_cwd
				local new_cwd = vim.fs.normalize(vim.v.event.cwd or ev.file)
				prev_cwd = new_cwd

				if old_cwd == new_cwd then
					return
				end

				-- Snapshot the currently loaded files (load order matters:
				-- parents first) and unload all of them.
				local loaded = vim.list_slice(loader.loaded.history)
				for _, path in ipairs(loaded) do
					pcall(loader.unload, path)
				end

				-- Re-root every previously loaded exrc under the new tree,
				-- keeping the same relative layout. Files that lived outside
				-- the old cwd are simply dropped.
				local candidates = {}
				local seen = {}
				local function add(path)
					path = vim.fs.normalize(path)
					if not seen[path] and vim.fn.filereadable(path) == 1 then
						seen[path] = true
						table.insert(candidates, path)
					end
				end

				add(vim.fs.joinpath(new_cwd, vim.g.workspace_file_name))
				for _, path in ipairs(loaded) do
					local rel = relative(vim.fs.normalize(path), old_cwd)
					if rel then
						add(vim.fs.joinpath(new_cwd, rel))
					end
				end

				for _, path in ipairs(candidates) do
					if not loader.is_loaded(path) then
						local ok, err = pcall(loader.load, path)
						if not ok then
							vim.notify(
								string.format("exrc: failed to load %s\n%s", path, err),
								vim.log.levels.WARN,
								{ title = "exrc" }
							)
						end
					end
				end
			end,
		})
		_G.workspace = require("internal.workspace")
	end)
