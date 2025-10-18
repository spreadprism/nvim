# Agent Guidelines for nvim Configuration

## Build/Test Commands
- No traditional build system - this is a Nix-based Neovim config
- Build: `nix build .#nvim` or `nix build .#nvim_dev`
- Dev shell: `nix develop`
- No test runner configured - test directory exists but no test framework found

## Code Style
- **Language**: Lua (Neovim configuration)
- **Tabs**: Use tabs (not spaces), `tabstop=2`, `shiftwidth=2`
- **Type annotations**: Use LuaLS annotations (`---@param`, `---@return`, `---@class`, `---@field`)
- **Module pattern**: `local M = {}` then `return M`
- **Global helpers**: Use global helper functions like `plugin()`, `lsp()`, `dap()`, `neotest()`, `formatter()`, `linter()`, `kmap()`, `kcmd()`, `klazy()`, `kgroup()`, `kopts()` (defined in `lua/internal/init.lua`)
- **Naming**: snake_case for functions and variables
- **Comments**: Use `-- TODO:`, `-- INFO:`, `-- NOTE:`, `-- FIXME:` prefixes
- **Conditionals**: Check Nix categories with `nixCats("category.subcategory")` before loading language-specific configs
- **Function definitions**: Standard Lua `function M.name()` or `local function name()`
- **Keymaps**: Use internal keymap system (`kmap`, `kgroup`, `kopts`) instead of raw `vim.keymap.set`
- **Plugins**: Define with global `plugin("name")` DSL using method chaining (`:opts()`, `:keys()`, `:cmd()`, `:ft()`, `:on_require()`)
- **LSP**: Define with `lsp("name"):ft():root_markers():settings()` pattern
- **No tests**: Currently no test framework configured
