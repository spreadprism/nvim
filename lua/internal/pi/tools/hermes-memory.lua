--- Tool renderers for the hermes memory tools (memory_*, session_search,
--- skill_manage). All of them render inline, like `read`:
---
---   󰻂 memory_search  favorite color preference
---   󰻂 memory_add  user: prefers concise answers
---   󰻂 skill_manage  create: debug-typescript-errors
local render = require("internal.pi.render")

--- Inline details have no window context, so cap them at a fixed width.
local MAX = 72

---@param value any
---@param width integer?
---@return string?
local function text(value, width)
	if type(value) ~= "string" then
		return nil
	end

	local trimmed = vim.trim(value:gsub("%s+", " "))
	if trimmed == "" then
		return nil
	end

	return render.truncate(trimmed, width or MAX)
end

--- `prefix: detail`, skipping empty parts.
---@param prefix string?
---@param detail string?
---@return string?
local function labeled(prefix, detail)
	if not detail then
		return prefix
	end

	if not prefix then
		return detail
	end

	return prefix .. ": " .. render.truncate(detail, MAX - #prefix - 2)
end

--- Scope hints for a search: `target/project/category`.
---@param args table?
---@return string?
local function scope(args)
	if type(args) ~= "table" then
		return nil
	end

	local parts = {}
	for _, key in ipairs({ "target", "project", "category" }) do
		if type(args[key]) == "string" and args[key] ~= "" then
			parts[#parts + 1] = args[key]
		end
	end

	return #parts > 0 and table.concat(parts, "/") or nil
end

--- `(n items)` for tool output, best effort.
---@param result table?
---@param is_error boolean?
---@param noun string
---@return string?
local function count_status(result, is_error, noun)
	local out = render.result_text(result)
	if not out or is_error then
		return nil
	end

	local count = 0
	for line in out:gmatch("[^\n]+") do
		if line:match("^%s*%d+%.%s") or line:match("^%s*[-*]%s") or line:match("^#+%s") then
			count = count + 1
		end
	end

	if count == 0 then
		return out:lower():match("no %w+ found") and "(none)" or nil
	end

	return "(" .. count .. " " .. noun .. (count == 1 and "" or "s") .. ")"
end

---@param inline_text fun(args: table?): string?
---@param inline_status (fun(result: table?, is_error: boolean?): string?)?
---@return pi.ToolRenderer
local function inline(inline_text, inline_status)
	return {
		inline = true,
		inline_text = inline_text,
		inline_status = inline_status,
	}
end

---@type table<string, pi.ToolRenderer>
return {
	--- 󰻂 memory_search  user: favorite color preference  (3 results)
	memory_search = inline(function(args)
		return labeled(scope(args), text(args and args.query))
	end, function(result, is_error)
		return count_status(result, is_error, "result")
	end),

	--- 󰻂 session_search  auth refactor discussion
	session_search = inline(function(args)
		return labeled(args and args.project, text(args and args.query))
	end, function(result, is_error)
		return count_status(result, is_error, "result")
	end),

	--- 󰻂 memory_add  project: uses nixCats for plugin management
	memory_add = inline(function(args)
		return labeled(scope(args), text(args and args.content))
	end),

	--- 󰻂 memory_replace  user: prefers concise answers
	memory_replace = inline(function(args)
		return labeled(scope(args), text(args and (args.content or args.old_text)))
	end),

	--- 󰻂 memory_remove  memory: stale note about foo
	memory_remove = inline(function(args)
		return labeled(scope(args), text(args and args.old_text))
	end),

	--- 󰻂 skill_manage  create: debug-typescript-errors
	skill_manage = inline(function(args)
		if type(args) ~= "table" then
			return nil
		end

		return labeled(text(args.action, 16), text(args.name or args.skill_id or args.section))
	end),
}
