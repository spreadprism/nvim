-- Thin helpers around overseer that we drive from keymaps.
--
-- Everything in here lazily requires `overseer`, so loading this module never
-- pulls the plugin in by itself.

local M = {}

--- Mirror overseer's own search-dir logic: parent dir of a real file buffer,
--- otherwise the cwd.
---@return string dir
local function search_dir()
	if vim.bo.buftype == "" then
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname ~= "" then
			return vim.fn.fnamemodify(bufname, ":p:h")
		end
	end
	return vim.fn.getcwd()
end

--- The most recently started task, or nil when there is none.
---@return overseer.Task|nil
local function last_task()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({
		sort = require("overseer.task_list").sort_newest_first,
	})

	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks available", vim.log.levels.WARN)
		return nil
	end

	return tasks[1]
end

--- Run a task, always showing the template picker even when only one template
--- matches. `overseer.run_task()` auto-runs the single match (see the
--- `#templates == 1` short-circuit in `overseer/commands.lua` run_template),
--- and there is no opts flag to defeat it, so we list templates ourselves and
--- always drive `vim.ui.select`, then delegate back to run_task by name.
function M.run_task()
	local overseer = require("overseer")
	local template = require("overseer.template")

	template.list({ dir = search_dir(), filetype = vim.bo.filetype }, function(templates)
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

--- Prompt for a shell command and run it straight away as a task, skipping the
--- template machinery entirely (what `:OverseerRunCmd` does without args, but
--- with our own cwd and name).
---@param opts? { cwd?: string, open?: boolean } `open` floats the output once
---  the task starts. Defaults to false.
function M.run_cmd(opts)
	opts = opts or {}

	vim.ui.input({ prompt = "Command: ", completion = "shellcmdline" }, function(cmd)
		if not cmd or vim.trim(cmd) == "" then
			return
		end

		local overseer = require("overseer")
		local task = overseer.new_task({
			cmd = cmd,
			name = cmd,
			cwd = opts.cwd or search_dir(),
		})
		task:start()

		if opts.open then
			task:open_output("float")
		end
	end)
end

--- Open the most recent task's output in a floating window. "open float" is
--- overseer's built-in action that calls `task:open_output("float")`.
function M.open_last_float()
	local task = last_task()
	if task then
		require("overseer").run_action(task, "open float")
	end
end

--- Rerun the most recent task. Uses overseer's built-in "restart" action, which
--- force-stops the task if it's still running and starts it again.
function M.rerun_last()
	local task = last_task()
	if task then
		require("overseer").run_action(task, "restart")
	end
end

return M
