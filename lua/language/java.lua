if not nixCats("language.java") then
	return
end
plugin("jdtls"):event_defer():config(false)

local function get_jdtls_cache_dir()
	return vim.fn.stdpath("cache") .. "/jdtls"
end

local function get_jdtls_workspace_dir()
	return get_jdtls_cache_dir() .. "/workspace"
end

local function get_jdtls_jvm_args()
	local env = os.getenv("JDTLS_JVM_ARGS")
	local args = {}
	for a in string.gmatch((env or ""), "%S+") do
		local arg = string.format("--jvm-arg=%s", a)
		table.insert(args, arg)
	end
	return unpack(args)
end

local root_markers1 = {
	-- Multi-module projects
	"mvnw", -- Maven
	"gradlew", -- Gradle
	"settings.gradle", -- Gradle
	"settings.gradle.kts", -- Gradle
	-- Use git directory as last resort for multi-module maven projects
	-- In multi-module maven projects it is not really possible to determine what is the parent directory
	-- and what is submodule directory. And jdtls does not break if the parent directory is at higher level than
	-- actual parent pom.xml so propagating all the way to root git directory is fine
	".git",
}
local root_markers2 = {
	-- Single-module projects
	"build.xml", -- Ant
	"pom.xml", -- Maven
	"build.gradle", -- Gradle
	"build.gradle.kts", -- Gradle
}

lsp("jdtls")
	:init_options({
		bundles = { exec("java-debug-path") },
		---@param dispatchers? vim.lsp.rpc.Dispatchers
		---@param config vim.lsp.ClientConfig
	})
	:cmd(function(dispatchers, config)
		local workspace_dir = get_jdtls_workspace_dir()
		local data_dir = workspace_dir

		if config.root_dir then
			data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
		end

		local config_cmd = {
			"jdtls",
			"-data",
			data_dir,
			get_jdtls_jvm_args(),
		}

		return vim.lsp.rpc.start(config_cmd, dispatchers, {
			cwd = config.cmd_cwd,
			env = config.cmd_env,
			detached = config.detached,
		})
	end)
	:root_markers(root_markers1, root_markers2)
