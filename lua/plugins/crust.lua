local ft = {
	"crust_input",
	"crust_output",
}
plugin("crust")
	:event("DeferredUIEnter")
	:cmd("Crust")
	:opts({
		extension = { enabled = true },
		preload = { pi = true },
	})
	:after(function()
		local Excerpt = require("crust.ui.chat.tools.excerpt")

		--- Output of the run, cut to the tail like the bash tool does, minus
		--- the `$ just <recipe> (exit 0)` line the tool echoes first: the title
		--- already says which recipe ran.
		---@param display Crust.Chat.Tools.Display
		---@return string[] lines
		---@return Crust.Ui.Ansi.Range[] ranges
		local function tail(display)
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

		-- `just` renders as the recipe alone, with the run's output under it.
		require("crust.ui.chat.tools").register("just", {
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
		})
	end)
	:keymaps({
		k:map("nx", "<M-p>", k:require("crust").smart(), "crust"),
		k:map("n", "<localleader>m", k:require("crust").model(), "model"):ft(ft),
		k:map("n", "<localleader>s", k:require("crust").sessions(), "session"):ft(ft),
		k:map("n", "<localleader>l", k:require("crust").session_last(), "last session"):ft(ft),
		k:map("n", "<localleader>n", k:require("crust").new_session(), "new session"):ft(ft),
		k:map("n", "<localleader>r", k:require("crust").rename_session(), "rename session"):ft(ft),
	})
