local M = {}

---@class kmapOpts: vim.keymap.set.Opts
---@field cond? fun()|boolean
---@field hidden? boolean
---@field icon? string|wk.Icon|fun():(wk.Icon|string)

---@return wk.Spec
---@param mode string | string[]
---@param key string
---@param action string | function
---@param desc string
---@param opts? kmapOpts
function M.kmap(mode, key, action, desc, opts)
	if type(mode) == "string" then
		mode = vim.split(mode, "")
	end

	opts = opts or {}
	return vim.tbl_deep_extend("keep", {
		key,
		action,
		mode = mode,
		desc = desc,
	}, opts)
end

---@return wk.Spec
---@param key string
---@param name string
---@param mapping wk.Spec[]
function M.kgroup(name, key, mapping)
	local group = { key, group = name }

	for _, map in ipairs(mapping) do
		map[1] = key .. map[1]
	end

	return {
		group,
		unpack(mapping),
	}
end

function M.klazy(module)
	return setmetatable({}, {
		__index = function(_, key)
			return function(...)
				local args = { ... }
				return function()
					return require(module)[key](unpack(args))
				end
			end
		end,
	})
end

return M
