--- Tool renderers for the Kagi MCP tools.
local render = require("internal.pi.render")

--- Parse the markdown returned by `kagi_search`.
---@param text string
---@return { index: integer, title: string, url: string? }[]
local function parse_search_results(text)
	local results = {}
	local current

	for line in text:gmatch("[^\n]+") do
		local index, title = line:match("^###%s+(%d+)%.%s+(.+)$")

		if index then
			current = { index = tonumber(index), title = vim.trim(title) }
			results[#results + 1] = current
		elseif current then
			local url = line:match("^%*%*URL:%*%*%s+(.+)$")
			if url then
				current.url = vim.trim(url)
			end
		end
	end

	return results
end

---@type table<string, pi.ToolRenderer>
return {
	--- Rendered inline, like `read`: `󰻂 kagi_extract example.com/page (42 lines)`
	kagi_extract = {
		inline = true,
		inline_text = function(args)
			local urls = args and args.urls

			if type(urls) == "string" then
				return render.pretty_url(urls)
			end

			if type(urls) ~= "table" or #urls == 0 then
				return nil
			end

			local text = render.pretty_url(urls[1])
			if #urls > 1 then
				text = text .. " +" .. (#urls - 1) .. " more"
			end

			return text
		end,
		inline_status = function(result)
			local text = render.result_text(result)
			if not text then
				return nil
			end

			local lines = select(2, text:gsub("\n", "\n")) + 1
			return "(" .. lines .. " lines)"
		end,
	},

	--- Full block: the query as input, one title + url pair per result.
	---
	--- ╭─ 󰻂 kagi_search
	--- │  goldfish  (5 results)
	--- ├────
	--- │  1. Goldfish - Wikipedia
	--- │     en.wikipedia.org/wiki/Goldfish
	--- ╰─  completed
	kagi_search = {
		input_visible = 1,
		output_visible = 24,
		on_start = function(history, args)
			local query = args and args.query
			if type(query) ~= "string" or query == "" then
				return
			end

			local chunks = { { render.truncate(query, render.body_width(history)), "PiToolCall" } }

			if type(args.limit) == "number" then
				chunks[#chunks + 1] = { "  (" .. args.limit .. " results)", "PiToolCollapsed" }
			end

			render.rows(history, { { chunks = chunks } })
		end,
		on_end = function(history, _, result, is_error, insert_at)
			local text = render.result_text(result)
			if not text then
				return insert_at
			end

			local results = parse_search_results(text)

			if is_error or #results == 0 then
				return render.raw_output(history, text, is_error and "PiToolError" or "PiToolOutput", insert_at)
			end

			local tools = require("pi.ui.chat.tools")
			local width = render.body_width(history)
			local rows = { { glyph = tools.GLYPHS.SEP, chunks = { { "" } } } }

			for _, entry in ipairs(results) do
				local prefix = string.format("%2d. ", entry.index)

				rows[#rows + 1] = {
					chunks = {
						{ prefix, "PiToolCollapsed" },
						{ render.truncate(entry.title, width - #prefix), "PiToolCall" },
					},
				}

				if entry.url then
					rows[#rows + 1] = {
						chunks = {
							{ "    " },
							{ render.truncate(render.pretty_url(entry.url), width - 4), "PiMention" },
						},
					}
				end
			end

			return render.rows(history, rows, insert_at)
		end,
	},
}
