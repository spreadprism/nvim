local M = {}

local patterns_ft = require("icons.pattern")

M.get_ext = function(name)
	for pattern, ext in pairs(patterns_ft) do
		if name:find(pattern) then
			return ext
		end
	end
	return name:match("^.*%.(.*)$") or ""
end

return M
