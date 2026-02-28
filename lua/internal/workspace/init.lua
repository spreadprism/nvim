local M = {}

-- TODO: sql connections

---@class exrc.Config
---@field exrc_name string

---@class Workspace
---
---@private
---@field ctx exrc.Context
---@field config exrc.Config
---@field workspaceFolder string
---@field dap_configs dap.Configuration[]
---@field group integer|string
local Workspace = {}
Workspace.__index = Workspace

function M:ctx()
	local ctx = setmetatable({
		ctx = require("exrc").init(),
		config = require("exrc.config"),
		dap_configs = {},
	}, Workspace)

	ctx.group = vim.api.nvim_create_augroup(ctx.ctx.exrc_path, { clear = true })
	ctx.workspaceFolder = ctx.ctx.exrc_dir

	ctx.ctx:on_unload(function()
		ctx.group = vim.api.nvim_create_augroup(ctx.ctx.exrc_path, { clear = true })
		self.dap_configs = {}
	end)

	return ctx
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
			cwd = self.workspaceFolder,
		}, cfg)
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
		local path = vim.fs.joinpath(self.workspaceFolder, dir, self.config.exrc_name)

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

---@param configs dap.Configuration[]
function Workspace:launch_configs(configs)
	local dap = require("dap")

	if not dap.providers.configs[self.workspaceFolder] then
		dap.providers.configs[self.workspaceFolder] = function(_)
			return self:enrich_config(self.dap_configs)
		end
	end

	for _, config in ipairs(configs) do
		table.insert(self.dap_configs, config)
	end
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

return M
