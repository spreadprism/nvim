local M = {}
--- Copilot-style inline completion.
---
--- `apply_raw_code_response` REPLACES the current line outright
--- (`nvim_buf_set_lines(buf, row, row + 1, ...)`), yet the plugin's built-in
--- instructions — still sent, since `quick_chat.instructions` is nil — say
--- "Output ONLY the code to insert/append at the [CURRENT LINE]". Obeying that
--- literally wipes whatever is already typed, so the prompt has to demand the
--- full line back. Markers available: [CURSOR POSITION] (1-indexed Column),
--- [BEFORE CURSOR], [CURRENT LINE], [AFTER CURSOR]; the line is not pre-split
--- at the cursor, the model has to use the column itself.
local inline_complete_prompt = table.concat({
	"Act as an inline autocomplete engine, like GitHub Copilot.",
	"Continue the text at the cursor: [CURSOR POSITION] gives the 1-indexed Column into [CURRENT LINE].",
	"Your output REPLACES [CURRENT LINE] entirely, so first reproduce [CURRENT LINE] verbatim up to that column — identical leading indentation, identical characters — then append your continuation.",
	"Never reword, reindent or drop what is already written, and keep any text trailing the cursor at the end of your output.",
	"Match the style and conventions visible in [BEFORE CURSOR] and [AFTER CURSOR].",
	"Finish only the current thought: the rest of the line, or a short block if the line clearly opens one.",
	"Output raw text only — no code fences, no backticks, no explanation, no trailing blank line.",
	"If you have nothing worth adding, return [CURRENT LINE] unchanged.",
}, " ")

---@param model? string
function M.inline_assistant(model)
	return require("internal.opencode.quick_chat").quick_chat({
		model = model,
		prompt = inline_complete_prompt,
	})
end

return M
