---@enum EnvrcStatus
local EnvrcStatus = {
	ALLOWED = 0,
	UNSET = 1,
	DENIED = 2,
}

---@class Direnv
---@field refresh boolean
---@field envrc table<string, EnvrcStatus>
local Direnv = {
	refresh = false,
	envrc = {},
}

local group = vim.api.nvim_create_augroup("Direnv", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		local basename = vim.fs.basename(path)
		if basename == ".envrc" then
			Direnv:status(path)
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		local basename = vim.fs.basename(path)
		if basename == ".envrc" then
			if Direnv.envrc[path] == EnvrcStatus.ALLOWED then
				Direnv:allow()
			end
		end
		Direnv:reload()
	end,
})

function Direnv:allow()
	local path = vim.api.nvim_buf_get_name(0)
	local basename = vim.fs.basename(path)

	if basename ~= ".envrc" then
		return
	end

	local dir = vim.fs.dirname(path)

	self.envrc[path] = EnvrcStatus.ALLOWED
	vim.system({ "direnv", "allow" }, { cwd = dir }):wait()
end

function Direnv:deny()
	local path = vim.api.nvim_buf_get_name(0)
	local basename = vim.fs.basename(path)

	if basename ~= ".envrc" then
		return
	end

	local dir = vim.fs.dirname(path)
	self.envrc[path] = EnvrcStatus.DENIED
	vim.system({ "direnv", "deny" }, { cwd = dir }):wait()
end

function Direnv:reload()
	if self.refresh then
		return
	end
	self.refresh = true
	local path = vim.api.nvim_buf_get_name(0)
	local dir = vim.fs.dirname(path)

	vim.system({ "direnv", "export", "json" }, { cwd = dir }, function(out)
		self.refresh = false
		if out.code ~= 0 then
			return
		end
		local stdout = out.stdout

		local ok, export = pcall(vim.json.decode, stdout)
		if not ok then
			return
		end

		vim.schedule(function()
			for k, v in pairs(export) do
				vim.fn.setenv(k, v)
			end
		end)
	end)
end

---@param path string
function Direnv:status(path)
	if self.refresh then
		return
	end
	self.refresh = true
	local dir = vim.fs.dirname(path)
	vim.system({ "direnv", "status", "--json" }, { cwd = dir }, function(out)
		if out.code == 0 then
			local ok, status = pcall(vim.json.decode, out.stdout)
			if ok then
				self.envrc[path] = status.state.foundRC.allowed
			end
		end
		self.refresh = false
	end)
end

return Direnv
