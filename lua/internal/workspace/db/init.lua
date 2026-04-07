local M = {}

---@class Connection
---@field id string
---@field name string
---@field type string
---@field url string

---@class WorkspaceSource : Source
---@field providers table<string, fun(): Connection[]>
---@field refreshing boolean
local WorkspaceSource = {
	providers = {},
	refreshing = false,
}

function WorkspaceSource:name()
	return "workspace"
end

---@return ConnectionParams[]
function WorkspaceSource:load()
	---@type ConnectionParams[]
	local conn = {}

	for _, provider in pairs(self.providers) do
		vim.list_extend(conn, provider())
	end

	return conn
end

function WorkspaceSource:refresh()
	if not self.refreshing then
		self.refreshing = true
		vim.defer_fn(function()
			require("dbee.api").core.source_reload("workspace")
			self.refreshing = false
		end, 300)
	end
end

---@param load fun(): Connection[]
---@param name string
function WorkspaceSource:register(name, load)
	self.providers[name] = load
end

---@param name string
function WorkspaceSource:clear(name)
	self.providers[name] = nil
end

M.source = WorkspaceSource

return M
