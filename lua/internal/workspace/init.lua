local M = {}

--- Keys of `dap.providers.configs` registered by workspaces, so they can be
--- dropped when the workspace goes away.
---@type table<string, true>
local dap_providers = {}

--- Drop every workspace-provided dap configuration (and terminate a running
--- session, since its config is about to disappear). Built-in providers and
--- `dap.configurations` set by `internal.loader.dap` are left alone.
function M.flush_dap()
	local ok, dap = pcall(require, "dap")
	if not ok then
		dap_providers = {}
		return
	end

	if dap.session() then
		pcall(dap.terminate)
	end

	for key in pairs(dap_providers) do
		dap.providers.configs[key] = nil
	end
	dap_providers = {}
end

--- Stop running LSP clients and re-attach the buffers, so clients are rooted
--- in the new tree and pick up the settings of the exrc that was just loaded
--- for it.
---@param names? string[] restrict to these client names (default: all)
function M.restart_lsp(names)
	local clients = vim.lsp.get_clients()
	if names then
		local wanted = {}
		for _, name in ipairs(names) do
			wanted[name] = true
		end
		clients = vim.tbl_filter(function(client)
			return wanted[client.name]
		end, clients)
	end

	if vim.tbl_isempty(clients) then
		return
	end

	for _, client in ipairs(clients) do
		client:stop(true)
	end

	-- Wait until the clients actually exited before re-attaching, otherwise
	-- `vim.lsp.enable` may skip buffers because a client is still shutting
	-- down. Poll instead of a fixed delay; give up after ~2s and fire anyway.
	local attempts = 40
	local function reattach()
		if attempts > 0 then
			for _, client in ipairs(clients) do
				if not client:is_stopped() then
					attempts = attempts - 1
					vim.defer_fn(reattach, 50)
					return
				end
			end
		end
		-- re-run only the FileType autocmds `vim.lsp.enable` registered (the
		-- `nvim.lsp.enable` group), not every FileType hook (ftplugins,
		-- treesitter, ...). This is what core itself does in lsp.enable().
		pcall(vim.cmd.doautoall, "nvim.lsp.enable FileType")
	end
	vim.defer_fn(reattach, 10)
end

---@class exrc.Config
---@field exrc_name string

---@class Workspace
---
---@field protected ctx exrc.Context
---@field private config exrc.Config
---@field workspaceDir string
---@field clear_db boolean
---@field private dap_configs dap.Configuration[]
---@field private group integer|string
local Workspace = {}
Workspace.__index = Workspace

function M:ctx()
	local utils = require("exrc.utils")
	local Context = require("exrc.context")

	local info = utils.get_load_info()
	if #info == 0 then
		error("Could not detect exrc information")
	end

	local exrc_path = info[1].path

	if not Context.loader.is_loaded(exrc_path) then
		Context.loader.mark_loaded(exrc_path)
	end

	local ctx = setmetatable({
		load_info = info,
		exrc_path = exrc_path,
		exrc_dir = vim.fs.dirname(exrc_path),
	}, Context)
	local workspace = setmetatable({
		ctx = ctx,
		workspaceDir = ctx.exrc_dir,
		group = vim.api.nvim_create_augroup(ctx.exrc_path, { clear = true }),
		config = require("exrc.config"),
		clear_db = false,
		dap_configs = {},
	}, Workspace)

	ctx:on_unload(function()
		workspace:unload()
	end)

	return workspace
end

function Workspace:unload()
	self.group = vim.api.nvim_create_augroup(self.ctx.exrc_path, { clear = true })
	self.dap_configs = {}
end

---@param fn fun()
function Workspace:on_unload(fn)
	self.ctx:on_unload(fn)
end

---@private
---@param config dap.Configuration|dap.Configuration[]
---@return dap.Configuration[]
function Workspace:enrich_config(config)
	local new_configs = {}
	if type(config) == "table" and not vim.islist(config) then
		config = { config }
	end

	for i, cfg in ipairs(config) do
		new_configs[i] = vim.tbl_deep_extend("force", {
			request = "launch",
			cwd = self.workspaceDir,
		}, cfg)

		local type = cfg.type
		for original, links in pairs(require("internal.loader.dap.adapter").links) do
			if vim.tbl_contains(links, cfg.type) then
				type = original
				break
			end
		end
		local exists, enrich = pcall(require, "internal.workspace.dap.type." .. type)
		if exists then
			new_configs[i] = enrich(new_configs[i])
		end
	end

	return require("internal.loader.dap.config").enrich_config(new_configs)
end

--- Source additional workspaces. This is useful for monorepos
--- or projects with multiple submodules.
--- ```lua
--- -- single workspace
--- workspace:source_workspace("subworkspace")
--- -- Multiple
--- workspace:source_workspace({ "submodule1", "submodule2" })
--- ```
---@param dirs string | string[]
function Workspace:source_workspace(dirs)
	if type(dirs) == "string" then
		dirs = { dirs }
	end

	for _, dir in ipairs(dirs) do
		local path = vim.fs.joinpath(self.workspaceDir, dir, self.config.exrc_name)

		if vim.fn.filereadable(path) == 1 then
			self.ctx.loader.load(path)
		else
			vim.notify(
				string.format("Workspace: No exrc file found at %s", path),
				vim.log.levels.WARN,
				{ title = "Workspace" }
			)
		end
	end
end

function Workspace:source_up()
	self.ctx:source_up({ quiet = true })
end

---@alias workspace.LspHandler vim.lsp.Config|fun(config: vim.lsp.Config, dir: string): vim.lsp.Config?

--- Per-workspace LSP settings, applied on top of the global `vim.lsp.config`
--- entry and reverted when the workspace is unloaded.
---
--- Handlers are either a config table (deep-merged) or a function mutating the
--- config in place (it may also return a replacement table).
---
--- ```lua
--- workspace:lsp({
---   gopls = { settings = { gopls = { buildFlags = { "-tags=integration" } } } },
---   lua_ls = function(cfg)
---     cfg.settings.Lua.workspace.library = { ... }
---   end,
--- })
--- ```
---
--- Note: `vim.lsp.config` is global, so only one workspace at a time can own a
--- given client. That is the exrc model anyway: entries are reverted on unload,
--- i.e. on every `DirChanged` reload.
---@param handlers table<string, workspace.LspHandler>
function Workspace:lsp(handlers)
	local names = {}

	-- `vim.lsp.config[name]` resolves runtime `lsp/` files on access, so the
	-- raw user entry is what must be put back on unload; handlers still build
	-- on top of the resolved config so they see the full picture.
	local raw_configs = rawget(vim.lsp.config, "_configs")

	for name, handler in pairs(handlers) do
		-- snapshot what was configured before this workspace touched it
		local previous ---@type vim.lsp.Config|nil
		if raw_configs then
			previous = raw_configs[name] ~= nil and vim.deepcopy(raw_configs[name]) or nil
		else
			previous = vim.deepcopy(vim.lsp.config[name] or {})
		end
		local config = vim.deepcopy(vim.lsp.config[name] or {})

		if type(handler) == "function" then
			config = handler(config, self.workspaceDir) or config
		else
			config = vim.tbl_deep_extend("force", config, handler)
		end

		vim.lsp.config[name] = config
		table.insert(names, name)

		self:on_unload(function()
			vim.lsp.config[name] = previous or {}
		end)
	end

	if vim.tbl_isempty(names) then
		return
	end

	-- a client may already be running with the previous settings. During a
	-- workspace switch the switch routine restarts everything once at the end,
	-- so only bounce clients here for standalone reloads (`:ExrcReloadAll`,
	-- editing the workspace file).
	if require("internal.workspace.switch").is_switching() then
		return
	end
	vim.schedule(function()
		M.restart_lsp(names)
	end)
end

---@param name string
---@param callback fun()
function Workspace:on_plugin(name, callback)
	event.on_plugin(name, callback, self.group)
end

---@param pattern string | string[]
---@param callback fun()
function Workspace:on_save(pattern, callback)
	event.on_save(pattern, callback, self.group)
end

---@param ft string
---@param configs Configuration|Configuration[]
---@overload fun(self, ft: "go", configs: GoConfiguration|GoConfiguration[])
---@overload fun(self, ft: "rust", configs: RustConfiguration|RustConfiguration[])
function Workspace:dap(ft, configs)
	local dap = require("dap")

	dap.providers.configs[self.workspaceDir] = function(_)
		return self.dap_configs
	end

	if not dap_providers[self.workspaceDir] then
		dap_providers[self.workspaceDir] = true
		self:on_unload(function()
			dap.providers.configs[self.workspaceDir] = nil
			dap_providers[self.workspaceDir] = nil
		end)
	end

	if not vim.islist(configs) then
		configs = { configs }
	end

	for _, cfg in ipairs(configs) do
		if ft then
			cfg.type = ft
		end

		local nconfigs = require("internal.workspace.dap.enrich")(self, cfg)
		if vim.islist(nconfigs) then
			vim.list_extend(self.dap_configs, nconfigs)
		else
			table.insert(self.dap_configs, nconfigs)
		end
	end
end

---@overload fun(self: Workspace, type: "mariadb", conn: MariadbConnection|MariadbConnection[])
---@overload fun(self: Workspace, type: "mysql", conn: MysqlConnection|MysqlConnection[])
---@overload fun(self: Workspace, type: "postgres", conn: PostgresConnection|PostgresConnection[])
---@param type string
---@param conn Connection|Connection[]
function Workspace:db(type, conn)
	local source = require("internal.workspace.db").source

	if not self.clear_db then
		self.clear_db = true
		self:on_unload(function()
			source:clear(self.workspaceDir)
			self.clear_db = false
		end)
	end

	if not vim.islist(conn) then
		conn = { conn }
	end

	local provider = require("internal.workspace.db." .. type)
	for _, c in ipairs(conn) do
		source:register(self.workspaceDir, provider(self, c))
	end
end

---@param ft string
---@param pattern string|string[]
function Workspace:set_ft(ft, pattern)
	vim.api.nvim_create_autocmd("BufEnter", {
		group = self.group,
		pattern = pattern,
		callback = function(args)
			if args and args.buf and vim.api.nvim_buf_is_valid(args.buf) then
				vim.bo[args.buf].filetype = ft
			end
		end,
	})
end

return M
