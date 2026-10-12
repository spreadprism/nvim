-- per workspace shadafile
local shada_dir = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "myshada")

---@param cwd string
---@return string
local function shada_path_for(cwd)
	cwd = vim.fs.normalize(cwd)
	local unique_id = vim.fn.fnamemodify(cwd, ":t") .. "_" .. vim.fn.sha256(cwd):sub(1, 8) ---@type string
	return vim.fs.joinpath(shada_dir, unique_id .. ".shada")
end

---@param cwd string
local function use_shada_for(cwd)
	local new = shada_path_for(cwd)
	if vim.o.shadafile == new then
		return
	end

	vim.fn.mkdir(shada_dir, "p")

	-- flush the current workspace's shada before switching away from it
	if vim.o.shadafile ~= "" and vim.o.shadafile:upper() ~= "NONE" then
		pcall(vim.cmd.wshada)
	end

	vim.o.shadafile = new

	-- merge in the new workspace's history (rshada errors if the file is absent)
	if vim.uv.fs_stat(new) then
		pcall(vim.cmd.rshada)
	end
end

use_shada_for(vim.fn.getcwd())

vim.api.nvim_create_autocmd("DirChanged", {
	group = vim.api.nvim_create_augroup("workspace_shada", { clear = true }),
	desc = "Use a per-workspace shadafile",
	callback = function(ev)
		-- only global cwd changes define "the" workspace
		if ev.match ~= "global" then
			return
		end
		use_shada_for(vim.v.event.cwd or vim.fn.getcwd())
	end,
})
