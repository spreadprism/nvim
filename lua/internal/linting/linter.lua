local utils = require("internal.linting.utils")
---@class Linter
---@field lang string | (string | table)[]
---@field name string
---@field mason_name string
---@field install_mason boolean
local Linter = {}
Linter.__index = Linter

---@param lang string | (string | table)[]
---@param name string
---@param mason_name string | nil
function Linter.new(lang, name, mason_name)
	local self = setmetatable({}, Linter)
	self.lang = lang
	self.name = name
	self.mason_name = mason_name or name
	self.install_mason = true
	utils.insert(self)
	return self
end

---@param install boolean
function Linter:install(install)
	self.install_mason = install
	return self
end

return Linter.new
