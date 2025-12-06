# How to gather task context

When working on tasks, gather relevant context by examining the codebase structure, dependencies, and configuration files. Store any task-specific notes or analysis in `./.agents/tasks` (create the directory if it doesn't exist). This includes understanding the Neovim setup, Nix configurations, and how nixCats manages plugins and categories.

## repo information

This is a Neovim configuration managed using nixCats, a framework that leverages Nix for reproducible and modular Neovim setups. It allows defining different "categories" of configurations with specific plugins and settings.

- `lua/`: Neovim configuration written in Lua
  - `lua/nixCats/`: Core nixCats Lua modules for configuration management, including nixcats.lua (main module) and utils.lua (utility functions)
  - `lua/init_*.lua`: Initialization files for different aspects:
    - `init_lze.lua`: Likely for the lze plugin manager
    - `init_nixcats.lua`: nixCats-specific initialization
    - `init_opts.lua`: General options setup
- `nix/`: Nix configuration for managing the configuration's dependencies
  - `nix/categories/`: Defines different configuration categories (e.g., core.nix for base settings)
  - `nix/overlays/`: Custom Nix overlays for additional packages (e.g., codelldb.nix for debugging tools)
  - `nix/plugins/`: Plugin-specific configurations, including its own flake.nix for plugin dependencies
  - `nix/categories.nix`: Central file defining available categories
- Root files:
  - `flake.nix` and `flake.lock`: Main Nix flake for the entire configuration
  - `init.lua`: Entry point for Neovim configuration
  - `.envrc`: Direnv configuration for environment setup
  - `README.md`: Project documentation
