# Repository Structure

This is a Neovim configuration managed with nixCats and Nix flakes.

## Directory Structure

### `/nix/` - Nix Configuration
- **`/nix/categories/`** - Plugin and dependency groupings
  - `core/*.nix` - Core plugins and runtime dependencies
  - `langs/*.nix` - Language-specific dependencies and tooling (go.nix, java.nix, lua.nix, etc.)
- **`/nix/overlays/`** - Custom package overlays
  - `default.nix` - Overlay registry
  - Individual overlays for custom packages (java.nix, codelldb.nix, commit-lsp.nix, etc.)
- **`/nix/plugins/flake.nix`** - Plugin sources from GitHub/external repos

### `/lua/` - Lua Configuration
- **`/lua/plugins/`** - Plugin configurations using lze (lazy loading)
  - Plugin specs follow the pattern: `plugin("name"):event():opts():keymaps()`
- **`/lua/language/`** or `/lua/langs/`** - Language-specific LSP and tooling configuration
  - Each file configures LSP, formatters, and linters for a specific language
- **`/lua/internal/`** - Internal utilities and helpers
- **`/lua/inits/`** - Initialization scripts
- **`/lua/nixCats/`** - nixCats integration helpers

### `/.agents/` - AI Agent Context
- **`/.agents/tasks/`** - Task-specific documentation and workflows
- **`/.agents/contexts/`** - Context files for specific operations

### `/test/` - Test projects
- Language-specific test directories for trying out configurations
- for example `/test/go` contains an go repo example

## Key Concepts

### Plugin Management
- Plugins are defined in `/nix/plugins/flake.nix` as flake inputs
- Plugins are added to categories in `/nix/categories/`
- Lua configuration goes in `/lua/plugins/` using the lze lazy-loading system
- Pattern: Nix defines what's available, Lua configures how it's used

### Adding a Plugin
1. Add to `/nix/plugins/flake.nix` as an input
2. Add to appropriate category in `/nix/categories/`
3. Run `just update_plugins`
4. Add minimal Lua config: `plugin("name")` in appropriate `/lua/plugins/` file

### LSPs and Runtime Dependencies
- Defined in category files under `lspsAndRuntimeDeps`
- LSP configuration in `/lua/language/` files using `lsp("name")` helper

### Overlays
- Custom packages defined in `/nix/overlays/`
- Registered in `/nix/overlays/default.nix`
- Referenced in categories as `pkgs.package-name`

# How to gather task context

When working on tasks, gather relevant context by examining the codebase structure, dependencies, and configuration files. Store any task-specific notes or analysis in `./.agents/tasks` (create the directory if it doesn't exist). This includes understanding the Neovim setup, Nix configurations, and how nixCats manages plugins and categories.

Refer to files in `./.agents/contexts/` for additional guidance on gathering specific information when you lack the necessary details for a task.
