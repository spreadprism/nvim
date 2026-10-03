--- Display specs for the Kagi tools.
---
--- `kagi_extract` is inline, like `read`:
---
---   󰖟 kagi_extract: en.wikipedia.org/wiki/Goldfish  42 lines
---
--- `kagi_search` shows the query as title and the hits as body:
---
---   󰖟 kagi_search: goldfish  (5 results)
---    1. Goldfish - Wikipedia
---       en.wikipedia.org/wiki/Goldfish

--- Longest body line before it gets cut; the title is cut by crust already.
local MAX = 100

---@param url any
---@return string?
local function pretty_url(url)
	if type(url) ~= "string" or url == "" then
		return nil
	end

	local text = url:gsub("^%w+://", ""):gsub("^www%.", ""):gsub("/$", "")
	return text
end

---@param text string
---@param width integer
---@return string
local function truncate(text, width)
	if vim.fn.strdisplaywidth(text) <= width then
		return text
	end

	return vim.fn.strcharpart(text, 0, math.max(width - 1, 1)) .. "…"
end

--- Parse the markdown returned by `kagi_search`.
---@param text string
---@return { index: integer, title: string, url: string? }[]
local function parse_results(text)
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

---@type Crust.Chat.Tools.Spec
local extract = {
	-- A line count fits on the title line, an error message does not.
	inline = function(display)
		return display.status ~= "error"
	end,

	title = function(display)
		local urls = display.args.urls

		if type(urls) == "string" then
			return pretty_url(urls) or ""
		end

		if type(urls) ~= "table" or #urls == 0 then
			return ""
		end

		local text = pretty_url(urls[1]) or ""
		if #urls > 1 then
			text = text .. " +" .. (#urls - 1) .. " more"
		end

		return text
	end,

	body = function(display)
		if display.status == "error" then
			return display:result_text()
		end

		local text = display:result_text()
		if not text or vim.trim(text) == "" then
			return nil
		end

		local count = select(2, text:gsub("\n", "\n")) + 1
		return { count .. " lines" }
	end,
}

---@type Crust.Chat.Tools.Spec
local search = {
	title = function(display)
		local query = display.args.query
		if type(query) ~= "string" or query == "" then
			return ""
		end

		local title = (query:gsub("%s+", " "))
		if type(display.args.limit) == "number" then
			title = title .. "  (" .. display.args.limit .. " results)"
		end

		return title
	end,

	body = function(display)
		local text = display:result_text()
		if not text or vim.trim(text) == "" then
			return nil
		end

		if display.status == "error" then
			return text
		end

		local results = parse_results(text)
		if #results == 0 then
			-- Not the shape we know: let the raw answer speak for itself.
			local Excerpt = require("crust.ui.chat.tools.excerpt")
			return (Excerpt.of(display, { from = "head" }))
		end

		local lines = {}
		for _, entry in ipairs(results) do
			local prefix = string.format("%2d. ", entry.index)
			lines[#lines + 1] = prefix .. truncate(entry.title, MAX - #prefix)

			local url = pretty_url(entry.url)
			if url then
				lines[#lines + 1] = "    " .. truncate(url, MAX - 4)
			end
		end

		return lines
	end,
}

return {
	kagi_extract = extract,
	kagi_search = search,
}
