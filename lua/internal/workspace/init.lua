local M = {}

-- TODO: sql connections

---@class exrc.Config
---@field exrc_name string

---@class Workspace
---
---@field protected ctx exrc.Context
---@field private config exrc.Config
---@field workspaceDir string
---@field buildDir string
---@field private dap_configs dap.Configuration[]
---@field private group integer|string
local Workspace = {}
Workspace.__index = Workspace

function M:ctx()
	local ctx = require("exrc").init()
	local workspace = setmetatable({
		ctx = ctx,
		workspaceFolder = ctx.exrc_dir,
		buildDir = vim.fs.joinpath(ctx.exrc_dir, "dist"),
		group = vim.api.nvim_create_augroup(ctx.exrc_path, { clear = true }),
		config = require("exrc.config"),
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

---@param handlers table<string, exrc.lsp.OnNewConfig>
function Workspace:lsp(handlers)
	self.ctx:lsp_setup(handlers)
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
function Workspace:dap(ft, configs)
	local dap = require("dap")
	dap.providers.configs[self.workspaceDir] = function(_)
		return self.dap_configs
	end

	if not vim.islist(configs) then
		configs = { configs }
	end

	for _, cfg in ipairs(configs) do
		if ft then
			cfg.type = ft
		end

		table.insert(self.dap_configs, require("internal.workspace.dap.enrich")(self, cfg))
	end
end

return M
