local M = {}
local dashboard_preview = require("dashboard.preview")

local dashboard_id = vim.fn.localtime()
vim.cmd("silent !mkdir " .. vim.fs.joinpath(vim.fn.stdpath("data"), "dashboard"))

local get_dir = function()
	return vim.fs.joinpath(vim.fn.stdpath("data"), "dashboard")
end

---@param id string
local get_path = function(id)
	return vim.fs.joinpath(get_dir(), id)
end

if not vim.fn.executable("figlet") then
	vim.notify("figlet executable not found", vim.log.levels.WARNING, { title = "LspConfig" })
end
if not vim.fn.executable("lolcat") then
	vim.notify("figlet executable not found", vim.log.levels.WARNING, { title = "LspConfig" })
end

local refresh_header = function(header_txt, width, id)
	if vim.fn.executable("figlet") and vim.fn.executable("lolcat") then
		local path = get_path(id)
		if not vim.fn.exists(get_dir()) then
			vim.cmd("silent !mkdir " .. get_dir())
		end
		vim.cmd("silent !rm -f " .. path)
		local header_cmd = "figlet -c -w " .. width .. " -f 'ANSI Shadow' " .. header_txt .. " > " .. path
		vim.cmd("silent !" .. header_cmd)
	else
		vim.notify("dependencies not available")
	end
end

local header_path = get_path(dashboard_id)
local preview_cmd = "cat | lolcat"
local preview_height = 6
local preview_width = vim.api.nvim_win_get_width(0) - 40

refresh_header(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), preview_width, dashboard_id)

if vim.o.filetype == "lazy" then
	vim.cmd.close()
	vim.api.nvim_create_autocmd("User", {
		pattern = "DashboardLoaded",
		callback = function()
			require("lazy").show()
		end,
	})
end

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

M.generate_config_config = function()
	return {
		center = center(),
		footer = footer,
	}
end

M.generate_config_preview = function()
	return {
		command = preview_cmd,
		file_path = header_path,
		file_width = preview_width,
		file_height = preview_height,
	}
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
		refresh_header(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), preview_width, dashboard_id)
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

return M
