local M = {}
local keybind_groups_registed_before_whichkey = {}

M.insert_group = function(group)
	table.insert(keybind_groups_registed_before_whichkey, group)
end
M.get_groups = function()
	return keybind_groups_registed_before_whichkey
end

return M
