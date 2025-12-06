# Step 4: Add plugin to category

The user should specify a category (e.g., "core") and plugin type (`startupPlugins` or `optionalPlugins`). If not provided, ask for it. Add the plugin to the corresponding category file (e.g., `nix/categories/core.nix`) in the specified list, using the plugin name from `nvim_pkgs` (e.g., `snacks` in `with nvim_pkgs; [snacks]`). Plugins added via GitHub URL are always from `nvim_pkgs`; ensure it's imported as an input if not already present.

Template for adding to `startupPlugins`:

```nix
{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  startupPlugins = with vim_pkgs;
    [
      # existing plugins
    ]
    ++ (with nvim_pkgs; [
      # existing nvim plugins
      plugin-name
    ]);
}
```