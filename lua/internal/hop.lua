-- INFO: most of the warnings weren't needed
---@diagnostic disable: missing-fields, missing-parameter
local M = {}

M.hop_word = function()
	local hop = require("hop")
	local ok, oil = pcall(require, "oil")
	if not ok or oil.get_current_dir() == nil then
		hop.hint_words()
	else
		hop.hint_lines()
	end
end

M.hop_char_global = function()
	require("hop").hint_char1()
end

---@param after? boolean
---@param offset? integer
M.hop_char_line = function(after, offset)
	if after == nil then
		after = true
	end
	offset = offset or 0
	return function()
		local directions = require("hop.hint").HintDirection
		local direction = directions.BEFORE_CURSOR
		if after then
			direction = directions.AFTER_CURSOR
		end
		require("hop").hint_char1({
			direction = direction,
			current_line_only = true,
			hint_offset = offset,
		})
	end
end

return M
