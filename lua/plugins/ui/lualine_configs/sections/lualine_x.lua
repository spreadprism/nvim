local overseer = function()
	local ok, _
	pcall(require, "overseer")
	if ok then
		return {
			"overseer",
			unique = true,
			symbols = {
				[require("overseer").STATUS.RUNNING] = "󰦖 ",
			},
		}
	end
	return {}
end

return {
	function()
		local all_clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() }) or {}

		local displays = {}
		for _, client in pairs(all_clients) do
			local name = client.name
			table.insert(displays, name)
		end

		return table.concat(displays, " | ")
	end,
}
