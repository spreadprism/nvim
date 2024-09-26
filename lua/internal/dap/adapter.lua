local utils = require("internal.dap.utils")
---@class Adapter
---@field name string
---@field opts table
---@field init boolean
---@field mason_install boolean | string
local Adapter = {}
Adapter.__index = Adapter

---@param adapter_name string
function Adapter.new(adapter_name, opts)
	local self = setmetatable({}, Adapter)
	self.name = adapter_name
	self.opts = opts
	self.init = true
	self.mason_install = true
	utils.insert_adapter(self)
	return self
end

---@param install boolean | string
function Adapter:mason(install)
	self.install = install
	return self
end

---@param init boolean
function Adapter:initialize(init)
	self.init = init
	return self
end

return Adapter.new
