local dash_utils = require("utils.dashboard")
local dashboard_preview = require("dashboard.preview")

local dashboard_id = vim.fn.localtime()

local header_path = dash_utils.get_path(dashboard_id)
local preview_cmd = "cat | lolcat"
local preview_height = 6
local preview_width = vim.api.nvim_win_get_width(0) - 40

dash_utils.refresh_header(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), preview_width, dashboard_id)
if vim.o.filetype == "lazy" then
	vim.cmd.close()
	vim.api.nvim_create_autocmd("User", {
		pattern = "DashboardLoaded",
		callback = function()
			require("lazy").show()
		end,
	})
end

local close_preview_buffer = function()
	local preview_ft = "dashboardpreview"
	local buffers = vim.api.nvim_list_bufs()
	-- Iterate through each buffer
	for _, buf in ipairs(buffers) do
		-- Check if the buffer is loaded and has the target file type
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "filetype") == preview_ft then
			-- Close the buffer
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		vim.cmd("!rm -f " .. header_path)
	end,
})
vim.api.nvim_create_autocmd("DirChanged", {
	pattern = "global",
	callback = function()
		dash_utils.refresh_header(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), preview_width, dashboard_id)
		if vim.bo.filetype == "dashboard" then
			close_preview_buffer()
			dashboard_preview:open_preview({
				width = vim.api.nvim_win_get_width(0) - 40,
				height = preview_height,
				cmd = preview_cmd .. " " .. header_path,
			})
		end
	end,
})
vim.api.nvim_create_autocmd("BufLeave", {
	callback = function()
		if vim.bo.filetype == "dashboard" then
			close_preview_buffer()
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.bo.filetype == "dashboard" then
			dashboard_preview:open_preview({
				width = vim.api.nvim_win_get_width(0) - 40,
				height = preview_height,
				cmd = preview_cmd .. " " .. header_path,
			})
		end
	end,
})

local center = function()
	local center = {
		{
			action = "SessionRestore",
			desc = " Load session",
			icon = " ",
			key = "l",
		},
		{
			action = function()
				-- list all buffer of filetype dashboardpreview
				vim.cmd("only")
				vim.cmd("Neogit")
			end,
			desc = " Neogit",
			icon = "󰊢 ",
			key = "g",
		},
		{
			action = function()
				-- list all buffer of filetype dashboardpreview
				vim.cmd("only")
				vim.cmd("Leet")
			end,
			desc = " Leetcode",
			icon = "󰓾 ",
			key = "L",
		},
		{
			action = function()
				-- If cwd is not nvim config dir, change to it
				local path = vim.fn.expand(vim.fn.stdpath("config"))
				if vim.fn.getcwd() ~= path then
					vim.cmd("only")
					vim.cmd("cd " .. path)
					vim.cmd("Dashboard")
				end
			end,
			desc = " Neovim configs",
			icon = " ",
			key = "c",
		},
		{
			action = function()
				vim.cmd("Lazy")
			end,
			desc = " Plugins",
			icon = "󰐱 ",
			key = "p",
		},
		{
			action = "bd",
			desc = " Close dashboard",
			icon = " ",
			key = "x",
		},
		{
			action = "qa",
			desc = " Quit",
			icon = " ",
			key = "q",
		},
	}

	for _, button in ipairs(center) do
		button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
		button.key_format = "  %s"
	end

	return center
end
local footer = function()
	local stats = require("lazy").stats()
	-- sleep for 100ms
	local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
	local version = vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
	local n_spaces = 3

	local footer = {}

	for _ = 1, n_spaces do
		table.insert(footer, "")
	end

	table.insert(footer, "Loaded in " .. ms .. "ms")
	table.insert(footer, "v" .. version)

	return footer
end

require("dashboard").setup({
	theme = "doom",
	config = {
		-- header = require("configs.dashboard.header"), --your header
		center = center(), --your center
		footer = footer, --your footer
	},
	hide = {
		statusline = false,
	},
	preview = {
		command = preview_cmd,
		file_path = header_path,
		file_width = preview_width,
		file_height = preview_height,
	},
})
