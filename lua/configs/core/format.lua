vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		local should_format = vim.g.format_ft[vim.bo.filetype]
		if should_format ~= nil and not should_format then
			return
		end
		should_format = vim.g.format_ft["*"]
		if should_format ~= nil and not should_format then
			return
		end
		vim.cmd("silent FormatWriteLock")
	end,
})

plugin("mhartington/formatter.nvim"):event("VeryLazy"):config(function()
	local formatters = require("internal.formatting").list_formatters()
	local filetype = {
		["*"] = require("formatter.filetypes.any")["remove_trailing_whitespace"],
	}

	for _, formatter in ipairs(formatters) do
		if type(formatter.lang) == "table" then
			---@diagnostic disable-next-line: param-type-mismatch
			for _, lang in ipairs(formatter.lang) do
				local lang_source = lang or formatter.lang
				local require_path = "formatter.filetypes." .. lang_source
				filetype[lang] = { require(require_path)[formatter.name] }
			end
		else
			local lang_source = formatter.formatter_lang_source or formatter.lang
			local require_path = "formatter.filetypes." .. lang_source
			filetype[formatter.lang] = { require(require_path)[formatter.name] }
		end
	end

	---@diagnostic disable-next-line: undefined-field
	require("formatter").setup({
		filetype = filetype,
	})
end)
