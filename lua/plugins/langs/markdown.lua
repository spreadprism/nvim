local ft = { "markdown", "codecompanion" }
lsp("marksman"):cmd("marksman", "server"):ft(unpack(ft))
plugin("render-markdown"):dep_on("nvim-treesitter"):ft({ "markdown", "codecompanion" }):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "thick",
	},
})
formatter(ft, { "prettier" })
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	once = true,
-- 	callback = function(args)
-- 		if vim.tbl_contains(ft, vim.bo[args].ft) then
-- 			kopts({ buffer = args.buf }, {})
-- 		end
-- 	end,
-- })
