local utils = require("internal.formatting.utils")
---@class Formatter
---@field lang string | (string | table)[]
---@field name string
---@field mason_name string
---@field install_mason boolean
---@field formatter_lang_source string | nil
local Formatter = {}
Formatter.__index = Formatter

---@param lang string | (string | table)[]
---@param name string
---@param mason_name string | nil
---@param formatter_lang_source string | nil
function Formatter.new(lang, name, mason_name, formatter_lang_source)
	local self = setmetatable({}, Formatter)
	self.lang = lang
	self.name = name
	self.mason_name = mason_name or name
	self.install_mason = true
	self.formatter_lang_source = formatter_lang_source
	utils.insert(self)
	return self
end

---@param install boolean
function Formatter:install(install)
	self.install_mason = install
	return self
end

return Formatter.new
