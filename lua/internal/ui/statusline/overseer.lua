return {
	{
		static = {
			options = {
				include_ephemeral = true,
				colored = true,
			},
		},
		update = function(self)
			local ok, overseer = pcall(require, "overseer")
			if not ok then
				return false
			end

			return #(self.tasks or {}) ~= overseer.list_tasks(self.options)
		end,
		init = function(self)
			local ok, overseer = pcall(require, "overseer")
			if ok then
				self.tasks = overseer.list_tasks(self.options)
			else
				self.tasks = {}
			end
		end,
		provider = "󱁤",
		hl = function(self)
			---@type overseer.Task[]
			local tasks = self.tasks

			---@type overseer.Task
			local task = tasks[1]

			if task then
				if task.status == "RUNNING" then
					return { fg = colors.orange }
				end
				local delta = os.difftime(os.time(), task.time_end)

				if delta < 3 then
					if task.status == "FAILURE" then
						return { fg = colors.red }
					elseif task.status == "SUCCESS" then
						return { fg = colors.green }
					end
				end
			end
			return { link = "Comment" }
		end,
	},
}
