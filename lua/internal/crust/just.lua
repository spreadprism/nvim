--- Tool renderer for `just`: the title is the recipe alone and the body is the
--- run's output, cut to the tail like the bash tool does.
---
--- ╭─  just  test
--- │  …12 lines
--- │  Success: 42 tests
--- ╰─  completed

--- Output of the run, cut to the tail like the bash tool does, minus the
--- `$ just <recipe> (exit 0)` line the tool echoes first: the title already
--- says which recipe ran.
---@param display Crust.Chat.Tools.Display
---@return string[] lines
---@return Crust.Ui.Ansi.Range[] ranges
local function tail(display)
	local Excerpt = require("crust.ui.chat.tools.excerpt")

	local lines, ranges = Excerpt.of(display, { from = "tail" })
	if not (lines[1] or ""):match("^%$ ") then
		return lines, ranges
	end

	-- The excerpt is cached and shared, so shift copies of the ranges.
	local shifted = {}
	for _, range in ipairs(ranges) do
		if range.line > 1 then
			local copy = vim.deepcopy(range)
			copy.line = copy.line - 1
			shifted[#shifted + 1] = copy
		end
	end

	return vim.list_slice(lines, 2, #lines), shifted
end

---@type Crust.Chat.Tools.Spec
local just = {
	title = function(display)
		local recipe = display.args.recipe
		return type(recipe) == "string" and recipe or ""
	end,

	body = function(display)
		if display.status == "error" then
			return display:result_text()
		end

		local text = display:result_text()
		if not text or vim.trim(text) == "" then
			return nil
		end

		return (tail(display))
	end,

	body_highlights = function(display)
		if display.status == "error" then
			return nil
		end

		return select(2, tail(display))
	end,
}

return { just = just }
