# Step 6: Add plugin config file

Add a minimal plugin call to the appropriate file in `lua/plugins/`.

**Only add the plugin call with the plugin name:**

```lua
plugin("PLUGIN_NAME")
```

Replace `PLUGIN_NAME` with the actual plugin name (e.g., `gitsigns`, `neogit`).

**Example locations:**
- Git-related: `lua/plugins/git.lua`
- Core UI: `lua/plugins/core/ui/icons.lua`
- Core editing: `lua/plugins/core/editing/blink.lua`

**Do not** add any configuration options (`:opts()`, `:event()`, etc.) unless explicitly requested. Keep it minimal.