local M = {}

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
