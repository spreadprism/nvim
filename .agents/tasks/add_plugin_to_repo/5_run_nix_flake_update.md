# Step 5: Run nix flake update

**Important**: When adding a new plugin, you must run `nix flake update plugins` from the repository root to update the flake lock and fetch the new plugin.

```bash
nix flake update plugins
```

This updates all plugins. If you only want to update a specific plugin after it's already been added:

```bash
nix flake update plugins/${PLUGIN_NAME}
```

Replace `${PLUGIN_NAME}` with the actual plugin name (e.g., `gitsigns`).

After adding the plugin, you have two options to update the flake:

1. **Update all plugins** (necessary when adding a new plugin):

   ```bash
   nix flake update plugins
   ```

2. **Update a specific plugin**:

   ```bash
   nix flake update plugins/${PLUGIN_NAME}
   ```

   Replace `${PLUGIN_NAME}` with the actual plugin name (e.g., `gitsigns`).
