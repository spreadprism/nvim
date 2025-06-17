vim.filetype.add({
	extension = {
		tf = "terraform",
		http = "http",
		env = "dotenv",
		gotmpl = "gotmpl",
	},
	filename = {
		[".envrc"] = "dotenv",
	},
	pattern = {
		["%.env%.[%w_.-]+"] = "dotenv",
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
-- 	callback = function()
-- 		local parent = vim.fn.expand("%:p:h")
-- 		---@diagnostic disable-next-line: undefined-field
-- 		if vim.uv.fs_stat(vim.fs.joinpath(parent, ".helmignore")) then
-- 			vim.bo.filetype = "helm"
-- 		end
-- 		---@diagnostic disable-next-line: undefined-field
-- 		if vim.uv.fs_stat(vim.fs.joinpath(parent, "Chart.lock")) then
-- 			vim.bo.filetype = "helm"
-- 		end
-- 	end,
-- })
