plugin("todo-comments"):event("DeferredUIEnter"):opts({
	signs = false,
	highlight = {
		keyword = "fg",
		multiline = true,
		-- vimgrep regex, supporting the pattern TODO(name):
		pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
	},
	keywords = {
		TODO = { color = "todo" },
	},
	colors = {
		todo = { "@comment.todo", "#7AA2F7" },
	},
	search = {
		-- ripgrep regex, supporting the pattern TODO(name):
		pattern = [[\b(KEYWORDS)(\(\w*\))*:]],
	},
})
