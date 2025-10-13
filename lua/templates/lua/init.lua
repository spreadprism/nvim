local utils = require("new-file-template.utils")

return function(opts)
	local template = {
		{ pattern = "%.nvim", content = require("templates.lua.nvim") },
		{ pattern = ".*", content = require("templates.lua.base") },
	}

	return utils.find_entry(template, opts)
end
