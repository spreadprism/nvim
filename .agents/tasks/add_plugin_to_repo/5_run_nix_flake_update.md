# Step 5: Run nix flake update

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
