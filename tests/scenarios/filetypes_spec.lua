--- One scenario per language configured in `lua/langs/`.
---
--- Each spec opens a real file of that filetype, waits for the config to
--- settle, appends a line, saves, waits again, then puts the file back and
--- saves. The whole thing runs under the snacks profiler, and the last spec
--- prints the combined report.
---
--- These are *observational*: they assert only that the scenario completed on
--- the expected filetype. The numbers are the product, and they are printed,
--- not thresholded — LSP startup cost varies far too much between machines to
--- be a pass/fail gate.

local scenario = require("helpers.scenario")

---@class Lang.Spec
---@field label string
---@field filetype string expected 'filetype'
---@field file string path inside the throwaway workspace
---@field lines string[] initial contents
---@field insert string line appended during the write phase
---@field extra? table<string, string[]> sibling files (project roots, manifests)

---@type Lang.Spec[]
local langs = {
	{
		label = "container",
		filetype = "dockerfile",
		file = "Dockerfile",
		lines = { "FROM alpine:3.20", "RUN apk add --no-cache curl" },
		insert = "LABEL org.opencontainers.image.title=scenario",
	},
	{
		label = "git",
		filetype = "gitcommit",
		file = ".git/COMMIT_EDITMSG",
		lines = { "feat: scenario commit", "", "# Please enter the commit message" },
		insert = "# appended by the scenario spec",
	},
	{
		label = "go",
		filetype = "go",
		file = "main.go",
		lines = {
			"package main",
			"",
			'import "fmt"',
			"",
			"func main() {",
			'\tfmt.Println("scenario")',
			"}",
		},
		insert = "",
		extra = {
			["go.mod"] = { "module scenario", "", "go 1.22" },
		},
	},
	{
		label = "hcl",
		filetype = "terraform",
		file = "main.tf",
		lines = {
			'variable "name" {',
			'  type    = string',
			'  default = "scenario"',
			"}",
		},
		insert = "",
	},
	{
		label = "helm",
		filetype = "helm",
		file = "templates/deployment.yaml",
		lines = {
			"apiVersion: apps/v1",
			"kind: Deployment",
			"metadata:",
			"  name: {{ .Release.Name }}",
		},
		insert = "  namespace: default",
		extra = {
			["Chart.yaml"] = { "apiVersion: v2", "name: scenario", "version: 0.1.0" },
			["values.yaml"] = { "replicaCount: 1" },
		},
	},
	{
		label = "java",
		filetype = "java",
		file = "src/main/java/Main.java",
		lines = {
			"public class Main {",
			"    public static void main(String[] args) {",
			'        System.out.println("scenario");',
			"    }",
			"}",
		},
		insert = "",
		extra = {
			["pom.xml"] = { "<project><modelVersion>4.0.0</modelVersion></project>" },
		},
	},
	{
		label = "json",
		filetype = "json",
		file = "config.json",
		lines = { "{", '  "name": "scenario"', "}" },
		insert = "",
	},
	{
		label = "just",
		filetype = "just",
		file = "justfile",
		lines = { "default:", "  echo scenario" },
		insert = "",
	},
	{
		label = "lua",
		filetype = "lua",
		file = "scenario.lua",
		lines = { "local M = {}", "", "function M.run()", '\treturn "scenario"', "end", "", "return M" },
		insert = "-- appended by the scenario spec",
	},
	{
		label = "luau",
		filetype = "luau",
		file = "scenario.luau",
		lines = { "local value: string = \"scenario\"", "print(value)" },
		insert = "-- appended by the scenario spec",
	},
	{
		label = "markdown",
		filetype = "markdown",
		file = "README.md",
		lines = { "# scenario", "", "Some text with a [link](https://example.com)." },
		insert = "Appended by the scenario spec.",
	},
	{
		label = "nix",
		filetype = "nix",
		file = "flake.nix",
		lines = {
			"{",
			'  description = "scenario";',
			"  outputs = { self }: { };",
			"}",
		},
		insert = "",
	},
	{
		label = "proto",
		filetype = "proto",
		file = "scenario.proto",
		lines = {
			'syntax = "proto3";',
			"",
			"package scenario;",
			"",
			"message Item {",
			"  string name = 1;",
			"}",
		},
		insert = "",
		extra = {
			["buf.yaml"] = { "version: v1" },
		},
	},
	{
		label = "python",
		filetype = "python",
		file = "main.py",
		lines = { "def main() -> str:", '    return "scenario"', "", "", 'if __name__ == "__main__":', "    print(main())" },
		insert = "",
		extra = {
			["pyproject.toml"] = { "[project]", 'name = "scenario"', 'version = "0.1.0"' },
		},
	},
	{
		label = "rust",
		filetype = "rust",
		file = "src/main.rs",
		lines = { "fn main() {", '    println!("scenario");', "}" },
		insert = "",
		extra = {
			["Cargo.toml"] = { "[package]", 'name = "scenario"', 'version = "0.1.0"', 'edition = "2021"' },
		},
	},
	{
		label = "typescript",
		filetype = "typescript",
		file = "main.ts",
		lines = { "export function scenario(): string {", '  return "scenario";', "}" },
		insert = "",
		extra = {
			["package.json"] = { '{ "name": "scenario", "version": "0.1.0" }' },
			["tsconfig.json"] = { '{ "compilerOptions": { "strict": true } }' },
		},
	},
	{
		label = "javascript",
		filetype = "javascript",
		file = "main.js",
		lines = { "export function scenario() {", '  return "scenario";', "}" },
		insert = "",
		extra = {
			["package.json"] = { '{ "name": "scenario", "version": "0.1.0" }' },
		},
	},
	{
		label = "yaml",
		filetype = "yaml",
		file = "config.yaml",
		lines = { "apiVersion: v1", "kind: ConfigMap", "metadata:", "  name: scenario" },
		insert = "data: {}",
	},
}

-- These specs need the real config (plugins, langs, LSP). `just test` runs the
-- suite with tests/minimal_init.lua, where none of that exists; run them with
-- `just langs` instead of failing the unit suite.
local full_config = _G.plugin ~= nil and pcall(require, "snacks")

describe("filetype scenarios", function()
	if not full_config then
		it("needs the full config (run `just langs`)", function()
			print("  skipped: started without the user config; use `just langs`")
			assert.is_nil(_G.plugin)
		end)
		return
	end

	local booted = false

	before_each(function()
		-- headless nvim never fires UIEnter; without this the DeferredUIEnter
		-- plugins (conform, lint, treesitter, ...) never load
		if not booted then
			booted = true
			scenario.boot(1000)
		end
	end)

	for _, spec in ipairs(langs) do
		it("opens, edits and reverts a " .. spec.label .. " file", function()
			local result = scenario.run(spec)

			assert.is_nil(result.error)
			assert.are.equal(spec.filetype, result.filetype)
			assert.is_true(result.phases.total > 0)
		end)
	end

	it("reports every scenario", function()
		scenario.report()
		assert.are.equal(#langs, #scenario.results)
	end)
end)
