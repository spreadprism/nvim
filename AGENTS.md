# How to gather task context

When working on tasks, gather relevant context by examining the codebase structure, dependencies, and configuration files. Store any task-specific notes or analysis in `./.agents/tasks` (create the directory if it doesn't exist). This includes understanding the Neovim setup, Nix configurations, and how nixCats manages plugins and categories.

Refer to files in `./.agents/contexts/` for additional guidance on gathering specific information when you lack the necessary details for a task.

## repo information

This is a Neovim configuration managed using nixCats, a framework that leverages Nix for reproducible and modular Neovim setups. It allows defining different "categories" of configurations with specific plugins and settings.

- `lua/`: Neovim configuration written in Lua
  - `lua/nixCats/`: Core nixCats Lua modules for configuration management, including nixcats.lua (main module) and utils.lua (utility functions)
  - `lua/init_*.lua`: Initialization files for different aspects:
    - `init_lze.lua`: Likely for the lze plugin manager
    - `init_nixcats.lua`: nixCats-specific initialization
    - `init_opts.lua`: General options setup
- `nix/`: Nix configuration for managing the configuration's dependencies

  - `nix/categories/`: Defines different configuration categories (e.g., core.nix for base settings and necessary dependencies). Each category file can define three types of items:
  - `lspsAndRuntimeDeps`: LSP and CLI dependencies (e.g., `rust-analyzer`, `fd`; use `unstable.package` for unstable versions)
  - `startupPlugins`: Plugins from `vim_pkgs` and `nvim_pkgs` loaded at startup
  - `optionalPlugins`: Plugins from `vim_pkgs` (use `unstable.package` for unstable versions) and `nvim_pkgs` that are lazy loaded
    Categories can have subcategories like `language.rust` in files such as `language/rust.nix`, using a template like:

  ```nix
  {
    vim_pkgs,
    nvim_pkgs,
    ...
  }: {
  }
  ```

  - `nix/overlays/`: Custom Nix overlays for additional packages (e.g., codelldb.nix for debugging tools)
  - `nix/plugins/`: Plugin-specific configurations, including its own flake.nix for plugin dependencies
  - `nix/categories.nix`: Central file defining available categories

- Root files:
  - `flake.nix` and `flake.lock`: Main Nix flake for the entire configuration
  - `init.lua`: Entry point for Neovim configuration
  - `.envrc`: Direnv configuration for environment setup
  - `README.md`: Project documentation
