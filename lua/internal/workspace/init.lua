local M = {}

-- TODO: direnv support
-- TODO: add events (event.on_plugin, on_write)
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
local Workspace = {}
Workspace.__index = Workspace

function M:ctx()
	local ctx = setmetatable({
		ctx = require("exrc").init(),
		config = require("exrc.config"),
		dap_configs = {},
	}, Workspace)

	ctx.workspaceFolder = ctx.ctx.exrc_dir

	return ctx
end

---@private
---@param config dap.Configuration|dap.Configuration[]
function Workspace:enrich_config(config)
	if type(config) == "table" and not vim.islist(config) then
		config = { config }
	end

	for _, cfg in ipairs(config) do
		-- TODO: implement
	end

	require("internal.loader.dap.config").enrich_config(config)
end

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
	self.ctx:source_up({})
end

---@param handlers table<string, exrc.lsp.OnNewConfig>
function Workspace:lsp(handlers)
	self.ctx:lsp_setup(handlers)
end

---@param configs dap.Configuration[]
function Workspace:launch_configs(configs)
	local dap = require("dap")

	if dap.providers.configs[self.workspaceFolder] then
		self.ctx:on_unload(function()
			self.dap_configs = {}
			dap.providers.configs[self.workspaceFolder] = nil
		end)
	else
		dap.providers.configs[self.workspaceFolder] = function(_)
			self:enrich_config(self.dap_configs)
			return self.dap_configs
		end
	end

	for _, config in ipairs(configs) do
		table.insert(self.dap_configs, config)
	end
end

return M
