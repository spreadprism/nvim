local M = {}

---@class Connection
---@field id string
---@field name string
---@field type string
---@field url string

---@class WorkspaceSource : Source
---@field providers table<string, fun(): Connection[]>
---@field refreshing boolean
local WorkspaceSource = {}
local providers = {}

function WorkspaceSource:name()
	return "workspace"
end

---@return ConnectionParams[]
function WorkspaceSource:load()
	---@type ConnectionParams[]
	local conn = {}

	for _, provider in pairs(providers) do
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

---@param name string
---@param load fun(): Connection[]
function WorkspaceSource:register(name, load)
	if name == nil then
		return
	end
	providers[name] = load
end

---@param name string
function WorkspaceSource:clear(name)
	providers[name] = nil
end

M.source = WorkspaceSource

return M
