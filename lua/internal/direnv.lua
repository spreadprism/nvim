---"state": {
-- "foundRC": {
-- 			"allowed": 0,
-- 			"path": "/home/avalon/Projects/Public/nvim/.envrc"
-- 		},
-- 		"loadedRC": {
-- 			"allowed": 0,
-- 			"path": "/home/avalon/Projects/Public/nvim/.envrc"
-- 		}
-- 	}

---@class Direnv.Status
---@field config.ConfigDir string
---@field config.SelfPath string
---
---@field state table
---@field state.foundRC table
---@field state.foundRC.allowed number
---@field state.foundRC.path string
---
---@field state.loadedRC table
---@field state.loadedRC.allowed number
---@field state.loadedRC.path string

---@alias Direnv.Export table<string, string>

---@class Direnv
---@field cwd string
---@field allowed boolean
local Direnv = {}

function Direnv:new(cwd)
	local instance = setmetatable({ cwd = cwd, reallow = false }, { __index = self })
	instance:setup_autocmd()
	return instance
end

function Direnv:setup_autocmd()
	local group = vim.api.nvim_create_augroup("Direnv", { clear = true })

	local path = vim.fs.joinpath(self.cwd, ".envrc")
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(args)
      local current_path = vim.fs.normalize(args.file)
			if current_path == ".envrc" then
				local status = self:status()
				self.allowed = status and status.state.foundRC.allowed == 0
			end
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(args)
      local current_path = vim.fs.normalize(args.file)
			if current_path == ".envrc" then
				self:allow()
			end
			self:reload()
		end,
	})
end

function Direnv:set_cwd(cwd)
	self.cwd = cwd
	self:setup_autocmd()
end

function Direnv:allow()
	vim.system({ "direnv", "allow" }, { cwd = self.cwd }):wait()
end

function Direnv:reload()
	self:export(function(export)
		vim.schedule(function()
			for k, v in pairs(export) do
				vim.fn.setenv(k, v)
			end
		end)
	end)
end

function Direnv:deny()
	vim.system({ "direnv", "deny" }, { cwd = self.cwd }):wait()
end

---@return Direnv.Status?
function Direnv:status()
	local res = vim.system({ "direnv", "status", "--json" }, { cwd = self.cwd }):wait()

	if res.code == 0 then
		local ok, status = pcall(vim.json.decode, res.stdout)
		if ok then
			return status
		end
	end

	return nil
end

---@param on_export fun(export: Direnv.Export)
function Direnv:export(on_export)
	vim.system({ "direnv", "export", "json" }, { cwd = self.cwd }, function(out)
		if out.code ~= 0 then
			on_export({})
		end
		local stdout = out.stdout

		local ok, export = pcall(vim.json.decode, stdout)
		if not ok then
			on_export({})
		else
			on_export(export)
		end
	end)
end

return Direnv
