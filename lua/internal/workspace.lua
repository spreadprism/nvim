local M = {}

---@type string[]
local workspace_env_keys
---@type dap.Configuration[]
local dap_configurations
---@type integer
local workspace_group_id

function M.init()
	require("exrc").init()
	workspace_group_id = vim.api.nvim_create_augroup("workspace_on_save", { clear = true })
	dap_configurations = {}
	if nixCats("debugging") then
		local dap = require("dap")
		local cfg = dap.providers.configs
		if cfg["dap.workspace"] == nil then
			cfg["dap.workspace"] = function(_)
				return dap_configurations
			end
		end
	end
end

---@param env_files? string | string[]
function M.dotenv(env_files)
	env_files = env_files or { ".env", ".local.env" }
	if type(env_files) == "string" then
		env_files = { env_files }
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
---@param action string | fun()
function M.on_write(pattern, action)
	if type(action) == "string" then
		action = function()
			-- TODO: Implement overseer for task name
			print(action)
		end
	end
	M.autocmd("BufWritePost", {
		pattern = pattern,
		callback = action,
	})
end

---@param cfgs dap.Configuration | dap.Configuration[]
function M.launch_configs(cfgs)
	if #cfgs == 0 then
		cfgs = { cfgs }
	end
	for _, cfg in ipairs(cfgs) do
		cfg.request = cfg.request or "launch"
		---@diagnostic disable-next-line: inject-field
		cfg.console = cfg.console or "externalTerminal"
		---@diagnostic disable-next-line: inject-field
		cfg.cwd = cfg.cwd or cwd()
		table.insert(dap_configurations, cfg)
	end
end

---@param ft string
---@param cfgs dap.Configuration | dap.Configuration[]
function M.launch_configs_ft(ft, cfgs)
	if #cfgs == 0 then
		cfgs = { cfgs }
	end

	for i, cfg in ipairs(cfgs) do
		cfgs[i].type = cfg.type or ft
	end

	M.launch_configs(cfgs)
end

return M
