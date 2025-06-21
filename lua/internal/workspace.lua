---@diagnostic disable: inject-field
local M = {}

---
---@type string[]
local workspace_env_keys
---@type Configuration[]
local dap_configurations
---@type integer
local workspace_group_id

function M.init()
	require("exrc").init()
	workspace_group_id = vim.api.nvim_create_augroup("workspace_on_save", { clear = true })
	dap_configurations = {}
	vim.g.find_file_blacklist = {}
	require("internal.db").clear_connections()
	if nixCats("core.debugging") then
		local dap = require("dap")
		local cfg = dap.providers.configs
		if cfg["dap.workspace"] == nil then
			cfg["dap.workspace"] = function(_)
				return dap_configurations
			end
		end
	end
end

---@param ... string
function M.dotenv(...)
	local env_files = { ... }

	if #env_files == 0 then
		env_files = { ".env" }
	end

	local cwd = cwd()

	local load_env = function()
		if workspace_env_keys ~= nil then
			env.clear(workspace_env_keys)
		end
		workspace_env_keys = {}
		local envs = {}
		for _, path in ipairs(env_files) do
			path = joinpath(cwd, path)
			envs = vim.tbl_extend("force", envs, env.read_env(path))
		end
		for key, val in pairs(envs) do
			table.insert(workspace_env_keys, key)
			env.set(key, val)
		end
	end

	load_env()
	local patterns = {}

	for _, file in ipairs(env_files) do
		table.insert(patterns, vim.fn.glob(vim.fn.fnamemodify(file, ":p")))
	end

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = workspace_group_id,
		pattern = env_files,
		callback = load_env,
	})
end

---@param event string | string[]
---@param opts vim.api.keyset.create_autocmd
function M.autocmd(event, opts)
	if type(event) == "string" then
		event = { event }
	end

	vim.api.nvim_create_autocmd(
		event,
		vim.tbl_deep_extend("keep", {
			group = workspace_group_id,
		}, opts)
	)
end
---@param pattern string | string[]
---@param action string
function M.on_write(pattern, action)
	local callback = function()
		require("overseer").run_template({ name = action })
	end
	M.autocmd("BufWritePost", {
		pattern = pattern,
		callback = callback,
	})
end

---@class Configuration
---@field name string
---@field type? string
---@field request? "launch"|"attach"
---@field cwd? string

---@param cfgs Configuration | Configuration[]
function M.launch_configs(cfgs)
	if #cfgs == 0 then
		cfgs = { cfgs }
	end
	for _, cfg in ipairs(cfgs) do
		table.insert(dap_configurations, cfg)
	end
end

---@param ft string
---@param cfgs Configuration | Configuration[]
function M.launch_configs_ft(ft, cfgs)
	if #cfgs == 0 then
		cfgs = { cfgs }
	end

	for i, cfg in ipairs(cfgs) do
		cfgs[i].type = cfg.type or ft
	end

	M.launch_configs(cfgs)
end
---@param ... string
function M.grep_pattern_ignore(...)
	local ignore_pattern = { ... }

	local tmp = {}
	for _, pattern in ipairs(ignore_pattern) do
		table.insert(tmp, pattern)
	end
	vim.g.grep_blacklist_pattern = tmp
end

---@param name string cli task name
---@param cmd string|table cli task command
---@return string
function M.cli_task(name, cmd)
	if type(cmd) == "table" then
		cmd = table.concat(cmd, " ")
	end

	-- registry overseer task
	require("overseer").register_template({
		name = name,
		builder = function()
			return {
				cmd = cmd,
				cwd = cwd(),
				components = { "default" },
			}
		end,
	})

	return name
end

M.mysql = require("internal.db").add_mysql_conn

return M
