---
name: add-plugin
description: Add a new Neovim plugin to this nixCats config from a git repo URL — creates the flake input, category entry, runs the flake update, and adds a minimal lua config. Use when asked to add or install a Neovim plugin. Takes the repo URL as an argument.
---

# Add Plugin to Repo

Use when the user asks to add/install a Neovim plugin (usually giving a GitHub
repo like `nvim-lualine/lualine.nvim`) into this nixCats-managed config.

## Arguments

```
/skill:add-plugin <repo-url> [plugin-name] [category] [startupPlugins|optionalPlugins]
```

Arguments arrive appended to this skill as `User: <args>`.

- `<repo-url>` **(required)** — the git repo. Accepted forms, all normalized to
  `owner/repo`:
  - `nvim-lualine/lualine.nvim`
  - `https://github.com/nvim-lualine/lualine.nvim`
  - `git@github.com:nvim-lualine/lualine.nvim.git`
- `[plugin-name]` *(optional)* — overrides the derived name (see step 2).
- `[category]` *(optional)* — e.g. `core`, `git`, `ui`, or a lang; ask if missing.
- `[startupPlugins|optionalPlugins]` *(optional)* — defaults to asking the user.

If no argument was supplied at all, ask the user for the repo URL before doing
anything else.

## Procedure

### 1. Parse the repo URL argument
Normalize the argument to `owner/repo` by stripping any `https://github.com/`,
`git@github.com:` prefix and a trailing `.git`. The flake input url becomes
`github:owner/repo`. If a plugin name was also passed, use it verbatim and skip
step 2.

### 2. Derive name if needed
Derive from the repo name: `lualine.nvim` → `lualine`. Always strip prefixes and
suffixes like `-nvim`, `.nvim`, `nvim-`.

### 3. Add input to `nix/plugins/flake.nix`
Add into the `inputs` section:

```nix
    "plugin-name" = {
      url = "github:owner/repo";
      flake = false;
    };
```

### 4. Add plugin to a category
Ask the user for the category (e.g. `core`, `git`, `ui`, a lang) and the plugin
type (`startupPlugins` or `optionalPlugins`) if not provided. Add the plugin name
to the corresponding file under `nix/categories/` (e.g. `nix/categories/core/git.nix`).

Plugins added via GitHub URL always come from `nvim_pkgs`; make sure `nvim_pkgs`
is in the file's argument set.

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

### 5. Update the flake
From the repository root — required when adding a new plugin:

```bash
just update plugins
```

To update a single already-added plugin:

```bash
just update plugins/${PLUGIN_NAME}
```

### 6. Add minimal lua config
Add a minimal plugin call in the appropriate file under `lua/plugins/`:

```lua
plugin("PLUGIN_NAME")
```

But before adding the plugin call, check if the file already contains a plugin call, if it does you DO NOT add the plugin call.

Example locations:
- Git-related: `lua/plugins/git.lua`
- Core UI: `lua/plugins/core/ui/icons.lua`
- Core editing: `lua/plugins/core/editing/blink.lua`

## Pitfalls
- Do not assume the argument is already `owner/repo`; normalize full URLs and
  `.git` suffixes first.
- Do **not** add `:opts()`, `:event()`, keymaps, or any other config unless the
  user explicitly asks. Keep the lua entry minimal.
- Forgetting `just update plugins` means the plugin source is never fetched.
- Run `just` commands from the repository root, not from `nix/plugins/`.
- Keep the flake input name, the category entry name, and the lua `plugin("...")`
  name consistent.

## Verification
- `nix/plugins/flake.nix` contains the new input with `flake = false;`.
- The plugin name appears in the intended `nix/categories/**` list.
- `just update plugins` completes and `nix/plugins/flake.lock` contains the new node.
- Neovim starts and the plugin loads (`:lua print(vim.inspect(package.loaded))` or `:Lz` state).
