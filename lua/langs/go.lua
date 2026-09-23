lsp("gopls"):settings({
	gopls = {
		semanticTokens = true,
		directoryFilters = {
			"-/nix/**",
			string.format("-%s/**", os.getenv("GOPATH")),
		},
		["ui.inlayhint.hints"] = {
			constantValues = true,
			rangeVariableTypes = true,
		},
	},
})
linter("go", "golangcilint")
formatter("go", "gofumpt")

-- nvim-lint ships `golangcilint` as a *function* spec, and `try_lint` calls it
-- on every lint: it shells out to `go env GOMOD` (twice, each wrapped in a
-- `:cd` round trip) and `golangci-lint version`, all synchronously on the main
-- loop. That was ~73ms of freeze per `:w` in a go buffer.
--
-- The version is pinned by nix (golangci-lint v2) and the module root does not
-- move mid-session, so resolve the root with `vim.fs.root` and hardcode the v2
-- argument list. Nothing here spawns a process.
event.on_plugin("lint", function()
	local severities = {
		error = vim.diagnostic.severity.ERROR,
		warning = vim.diagnostic.severity.WARN,
		refactor = vim.diagnostic.severity.INFO,
		convention = vim.diagnostic.severity.HINT,
	}

	--- golangci-lint reports the whole package; keep the current buffer's issues.
	---@param output string
	---@param bufnr integer
	---@param cwd string
	---@return vim.Diagnostic[]
	local function parser(output, bufnr, cwd)
		if output == "" then
			return {}
		end

		local ok, decoded = pcall(vim.json.decode, output)
		if not ok or type(decoded) ~= "table" or type(decoded.Issues) ~= "table" then
			return {}
		end

		local current = vim.fs.normalize(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p"))
		local diagnostics = {}
		for _, item in ipairs(decoded.Issues) do
			local reported = vim.fs.normalize(item.Pos.Filename)
			local absolute = vim.fs.normalize(vim.fn.fnamemodify(cwd .. "/" .. item.Pos.Filename, ":p"))

			if current == reported or current == absolute then
				local line = item.Pos.Line > 0 and item.Pos.Line - 1 or 0
				local col = item.Pos.Column > 0 and item.Pos.Column - 1 or 0
				table.insert(diagnostics, {
					lnum = line,
					col = col,
					end_lnum = line,
					end_col = col,
					severity = severities[item.Severity] or severities.warning,
					source = item.FromLinter,
					message = item.Text,
				})
			end
		end
		return diagnostics
	end

	require("lint").linters.golangcilint = function()
		local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
		local root = vim.fs.root(0, { "go.work", "go.mod" })

		return {
			name = "golangcilint",
			cmd = "golangci-lint",
			stdin = false,
			append_fname = false,
			stream = "stdout",
			ignore_exitcode = true,
			parser = parser,
			cwd = root,
			args = {
				"run",
				"--output.json.path=stdout",
				-- overwrite anything the project's .golangci.yml may set
				"--output.text.path=",
				"--output.tab.path=",
				"--output.html.path=",
				"--output.checkstyle.path=",
				"--output.code-climate.path=",
				"--output.junit-xml.path=",
				"--output.teamcity.path=",
				"--output.sarif.path=",
				"--issues-exit-code=0",
				"--show-stats=false",
				"--path-mode=abs",
				-- inside a module golangci-lint wants the package directory;
				-- a standalone file has to be passed directly
				root and vim.fs.dirname(file) or file,
			},
		}
	end
end)
neotest("neotest-golang")({
	go_test_args = {
		"-v",
		"-count=1",
		"-parallel=4",
		"-timeout=0",
	},
	dap_mode = "manual",
	dap_manual_config = {
		type = "go",
		name = "neotest",
		request = "launch",
		mode = "test",
		outputMode = "remote",
	},
})
dap.adapter({ "go", "delve" }, function(callback, config)
	---@type dap.ServerAdapter
	local adapter = {
		type = "server",
	}

	if config.mode == "remote" and config.request == "attach" then
		adapter.host = config.host or "127.0.0.1"
		adapter.port = config.port or "38697"
	else
		adapter.port = "${port}"
		adapter.executable = {
			command = "dlv",
			args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
			detached = vim.fn.has("win32") == 0,
		}
	end
	callback(adapter)
end)
