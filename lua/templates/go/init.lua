local utils = require("new-file-template.utils")

return function(opts)
	local template = {
		{ pattern = ".*/main", content = require("templates.go.main") },
		{ pattern = ".*_test", content = require("templates.go.test") },
		{ pattern = ".*", content = require("templates.go.base") },
	}

	return utils.find_entry(template, opts)
end
