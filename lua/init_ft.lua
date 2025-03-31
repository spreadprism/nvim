vim.filetype.add({
	extension = {
		tf = "terraform",
		http = "http",
		env = "dotenv",
	},
	filename = {
		[".envrc"] = "dotenv",
	},
	-- pattern = {
	-- 	[".env.?.*"] = "dotenv", --> BUG: matched env_manager.py
	-- },
})
