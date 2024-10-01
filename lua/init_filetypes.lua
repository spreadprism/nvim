vim.filetype.add({
	extension = {
		tf = "terraform",
	},
	filename = {
		[".envrc"] = "dotenv",
	},
	pattern = {
		[".?env.?.*"] = "dotenv",
	},
})
