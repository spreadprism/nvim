--- Workspace discovery / sync lives in `internal.workspace.registry` so other
--- plugins (worktrunk) can register workspaces too.
local function registry()
	return require("internal.workspace.registry")
end

--- Pick a workspace and open it (changes cwd, which reloads exrc files).
local function pick()
	local ws = require("workspaces")
	local reg = registry()
	local current = ws.path() and reg.clean(ws.path()) or reg.clean(vim.fn.getcwd())

	local items = {}
	for i, entry in ipairs(ws.get()) do
		local path = reg.clean(entry.path)
		table.insert(items, {
			idx = i,
			score = 0,
			name = entry.name,
			text = entry.name .. " " .. path,
			file = path,
			dir = true,
			current = path == current,
		})
	end

	if vim.tbl_isempty(items) then
		vim.notify("No workspaces registered", vim.log.levels.WARN, { title = "Workspaces" })
		return
	end

	Snacks.picker.pick({
		source = "workspaces",
		title = "Workspaces",
		items = items,
		preview = "directory",
		format = function(item)
			return {
				{ item.current and "● " or "  ", "SnacksPickerDirectory" },
				{ item.name, "SnacksPickerLabel" },
				{ " " },
				{ vim.fn.fnamemodify(item.file, ":~"), "SnacksPickerComment" },
			}
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				require("workspaces").open(item.name)
			end
		end,
	})
end

local function rename()
	local name = registry().name_of()
	if not name then
		vim.notify("Current directory is not a workspace", vim.log.levels.WARN, { title = "Workspaces" })
		return
	end

	vim.ui.input({ prompt = "Rename workspace: ", default = name }, function(new_name)
		if new_name and new_name ~= "" and new_name ~= name then
			require("workspaces").rename(name, new_name)
		end
	end)
end

plugin("workspaces")
	:event("DeferredUIEnter")
	:opts({
		-- the plugin's own autocmds are off: `internal.workspace.switch` owns
		-- the whole DirChanged routine (exrc, dap, lsp, direnv, buffers, UI)
		-- and activates the workspace itself, so nothing runs twice
		auto_open = false,
		auto_dir = false,
		cd_type = "global",
		notify_info = false,
		sort = true,
		mru_sort = true,
	})
	:keymaps({
		k:group("workspace", "<leader>w", {
			k:map("n", "w", pick, "workspaces"),
			k:map("n", "a", function()
				registry().register()
			end, "add current dir"),
			k:map("n", "x", function()
				require("workspaces").remove()
			end, "remove current workspace"),
			k:map("n", "r", rename, "rename workspace"),
			k:map("n", "s", function()
				registry().sync()
			end, "sync workspaces"),
		}),
	})
	:after(function()
		registry().sync({ quiet = true })
		require("internal.workspace.switch").setup()

		-- `auto_open` relies on VimEnter, which already fired by the time this
		-- plugin loads: activate the workspace of the startup cwd ourselves
		local name = registry().name_of()
		if name then
			pcall(require("workspaces").open, name)
		end
	end)
