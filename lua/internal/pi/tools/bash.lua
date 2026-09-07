--- Tool renderer for `bash`: the command is rendered as a markdown ```sh block
--- so the history buffer's markdown treesitter parser highlights it as shell.
--- The output stays plain text and keeps PI's own collapse behaviour.
---
--- ╭─ 󰻂 bash
--- │  ```sh
--- │  echo foobar
--- │  ```
--- ├────
--- │  …12 lines
--- │  foobar
--- ╰─  completed
local render = require("internal.pi.render")

--- Output lines shown while the block is collapsed (`<Tab>` expands to all).
local OUTPUT_VISIBLE = 10

--- Fence language for the command block.
local LANG = "sh"

---@param text string
---@return string[]
local function lines_of(text)
	local lines = vim.split(text, "\n", { plain = true })

	-- drop trailing blank lines so the collapsed view isn't wasted on padding
	while #lines > 0 and vim.trim(lines[#lines]) == "" do
		lines[#lines] = nil
	end

	return lines
end

---@type table<string, pi.ToolRenderer>
return {
	bash = {
		--- `input_visible` is deliberately left unset (unlimited): the collapsed
		--- view keeps only the first N input lines, which would cut the ```sh fence
		--- in half and leave the rest of the buffer styled as a code block. Showing
		--- the command in full always keeps the fence balanced.
		output_visible = OUTPUT_VISIBLE,

		--- No highlight groups are attached to the command: extmark highlights
		--- (priority 200) would win over treesitter, and the point here is to let
		--- the markdown parser style the block.
		on_start = function(history, args)
			local command = args and (args.command or args.cmd)
			if type(command) ~= "string" or vim.trim(command) == "" then
				return
			end

			local rows = { { chunks = { { "```" .. LANG } } } }

			for _, line in ipairs(lines_of(command)) do
				rows[#rows + 1] = { chunks = { { line } } }
			end

			rows[#rows + 1] = { chunks = { { "```" } } }

			render.rows(history, rows)
		end,

		--- Full output as plain lines; PI collapses it to the last
		--- `OUTPUT_VISIBLE` lines (prefixed with `…N lines`) and `<Tab>` toggles
		--- back to the complete output.
		on_end = function(history, _, result, is_error, insert_at)
			local text = render.result_text(result)
			if not text then
				return insert_at
			end

			local lines = lines_of(text)
			if #lines == 0 then
				return insert_at
			end

			local tools = require("pi.ui.chat.tools")
			local hl = is_error and "PiToolError" or "PiToolOutput"
			local rows = { { glyph = tools.GLYPHS.SEP, chunks = { { "" } } } }

			for _, line in ipairs(lines) do
				rows[#rows + 1] = { chunks = { { line, hl } } }
			end

			return render.rows(history, rows, insert_at)
		end,
	},
}
