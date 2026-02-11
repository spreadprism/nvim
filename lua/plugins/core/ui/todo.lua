plugin("todo-comments"):event("DeferredUIEnter"):opts({
	highlight = {
		multiline = true,
		-- vimgrep regex, supporting the pattern TODO(name):
		pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
	},
	search = {
		-- ripgrep regex, supporting the pattern TODO(name):
		pattern = [[\b(KEYWORDS)(\(\w*\))*:]],
	},
})
