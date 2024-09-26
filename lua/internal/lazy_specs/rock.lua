local specs = require("internal.lazy_specs.specs")
---@class Rock
---@field specs table
---@field rock_url string
---@field is_plugin boolean
local Rock = {}
Rock.__index = Rock

---@param url string
function Rock.new(url)
	local self = setmetatable({}, Rock)
	self.is_plugin = true
	self.rock_url = url
	self.specs = {}
	table.insert(self.specs, 1, url)
	specs.insert(self)
	return self
end

return Rock.new
