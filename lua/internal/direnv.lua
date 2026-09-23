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

--- Files whose contents feed the environment: the .envrc itself and any dotenv
--- file it may source (`dotenv`/`dotenv_if_exists` in direnv stdlib).
---@param basename string
---@return boolean
local function is_env_file(basename)
	return basename == ".envrc" or basename == ".env" or vim.startswith(basename, ".env.")
end

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
		if vim.bo.ft == "oil" then
			return
		end
		local path = vim.api.nvim_buf_get_name(args.buf)
		local basename = vim.fs.basename(path)
		-- only these writes can change the environment
		if not is_env_file(basename) then
			return
		end

		-- editing an .envrc invalidates its trust hash, re-allow when it was
		-- already allowed before the write
		if basename == ".envrc" and Direnv.envrc[path] == EnvrcStatus.ALLOWED then
			Direnv:allow()
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
