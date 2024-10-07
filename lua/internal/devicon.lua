local M = {}

local patterns_ft = require("icons.pattern")

M.get_ext = function(name)
	for _, p_ft in pairs(patterns_ft) do
		local pattern = p_ft[1]
		local ext = p_ft[2]
		if name:find(pattern) then
			return ext
		end
	end
	return name:match("^.*%.(.*)$") or ""
end

return M
