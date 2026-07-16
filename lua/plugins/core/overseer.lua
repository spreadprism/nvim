-- Run a task, always showing the template picker even when only one template
-- matches. overseer.run_task() auto-runs the single match (see the
-- `#templates == 1` short-circuit in overseer/commands.lua run_template),
-- and there is no opts flag to defeat it, so we list templates ourselves and
-- always drive vim.ui.select, then delegate back to run_task by name.
local function run_task_always_pick()
	local overseer = require("overseer")
	local template = require("overseer.template")

	-- Mirror overseer's own search-dir logic: parent dir of a real file
	-- buffer, otherwise the cwd.
	local dir = vim.fn.getcwd()
	if vim.bo.buftype == "" then
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname ~= "" then
			dir = vim.fn.fnamemodify(bufname, ":p:h")
		end
	end

	template.list({ dir = dir, filetype = vim.bo.filetype }, function(templates)
		templates = vim.tbl_filter(function(tmpl)
			return not tmpl.hide
		end, templates)

		if #templates == 0 then
			vim.notify("No task templates found", vim.log.levels.WARN)
			return
		end

		vim.ui.select(templates, {
			prompt = "Tasks:",
			kind = "overseer_template",
			format_item = function(tmpl)
				if tmpl.desc then
					return string.format("%s (%s)", tmpl.name, tmpl.desc)
				end
				return tmpl.name
			end,
		}, function(tmpl)
			if not tmpl then
				return
			end

			-- Delegate to run_task by name so all of overseer's build /
			-- param-prompting logic is reused.
			overseer.run_task({ name = tmpl.name }, function(_, err)
				if err then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end)
		end)
	end)
end

-- Open the most recent task's output in a floating window. list_tasks with the
-- newest-first sort returns the last-started task at index 1; "open float" is
-- overseer's built-in action that calls task:open_output("float").
local function open_last_task_float()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({
		sort = require("overseer.task_list").sort_newest_first,
	})

	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks available", vim.log.levels.WARN)
		return
	end

	overseer.run_action(tasks[1], "open float")
end

-- Rerun the most recent task. Uses overseer's built-in "restart" action, which
-- force-stops the task if it's still running and starts it again.
local function rerun_last_task()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({
		sort = require("overseer.task_list").sort_newest_first,
	})

	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks available", vim.log.levels.WARN)
		return
	end

	overseer.run_action(tasks[1], "restart")
end

plugin("overseer")
	:opts({
		dap = false,
		templates = { "cargo", "vscode", "make", "just", "shell" },
		form = {
			border = "rounded",
		},
		task_win = {
			border = "rounded",
		},
		component_aliases = {
			default = {
				"on_exit_set_status",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
			},
		},
		task_list = {
			direction = "right",
			keymaps = {
				["<C-q>"] = "<CMD>close<CR>",
				["<Up>"] = "keymap.prev_task",
				["<Down>"] = "keymap.next_task",
				["<CR>"] = { "keymap.open", opts = { dir = "float" }, desc = "Open task output in float" },
				["<M-Tab>"] = { "keymap.open", opts = { dir = "tab" }, desc = "Open task output in tab" },
				["e"] = "keymap.run_action",
			},
		},
	})
	:cmd({
		"OverseerRun",
		"OverseerToggle",
		"OverseerQuickAction",
		"OverseerRunCmd",
	})
	:keymaps({
		k:map("n", "<M-t>", run_task_always_pick, "run task"),
		k:map("n", "r", run_task_always_pick, "run task"):ft("OverseerList"),
		k:group("tasks", "<leader>t", {
			k:map("n", "e", k:require("overseer").toggle(), "tasks explorer"),
			k:map("n", "o", open_last_task_float, "open last task in float"),
			k:map("n", "l", rerun_last_task, "rerun last task"),
		}),
	})
	:after(function()
		event.on_plugin("nvim-dap", function()
			require("overseer").enable_dap()
		end)
	end)
