local M = {}

local blacklist = {}
function M.display(client, buf)
	if vim.tbl_contains(blacklist, client.name) then
		return nil
	end

	local lsp = lsp(client.name)

	if lsp then
		if lsp.display == false then
			return nil
		end
		display = lsp.display or client.name
		if type(display) == "function" then
			display = display(client, buf)
		end
		return display
	end
	return nil
end

function M.display_blacklist(name)
	table.insert(blacklist, name)
end

M.lsp = require("internal.loader.lsp.lsp")

return M
