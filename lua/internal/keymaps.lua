local M = {}

---@class kmapOpts: vim.keymap.set.Opts
---@field cond? boolean|fun():boolean
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
	local map = vim.tbl_deep_extend("keep", {
		key,
		action,
		mode = mode,
		desc = desc,
	}, opts)

	return map
end

---@return wk.Spec
---@param key string
---@param name string
---@param mapping wk.Spec | wk.Spec[]
function M.kgroup(name, key, mapping)
	if type(mapping[1]) ~= "table" then
		mapping = { mapping }
	end
	local group = { key, group = name }

	for _, map in ipairs(mapping) do
		map[1] = key .. map[1]
	end

	return {
		group,
		unpack(mapping),
	}
end

---@return wk.Spec
---@param opts kmapOpts
---@param mapping wk.Spec | wk.Spec[]
function M.kopts(opts, mapping)
	if type(mapping[1]) ~= "table" then
		mapping = { mapping }
	end

	local map = {}
	for _, m in ipairs(mapping) do
		table.insert(opts, m)
	end

	for k, v in pairs(opts) do
		map[k] = v
	end

	return map
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

---@param ft string | string[]
---@param mapping wk.Spec | wk.Spec[]
function M.kfiletype(ft, mapping)
	if type(ft) ~= "table" then
		ft = { ft }
	end
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = function(args)
			require("which-key").add(kopts({
				buffer = args.buf,
			}, mapping))
		end,
	})
end

return M
