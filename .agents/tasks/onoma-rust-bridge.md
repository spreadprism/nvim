# onoma.nvim Rust bridge integration

## Problem
`onoma.nvim` (github:ryanmab/onoma.nvim) needs a Rust "bridge" dynamic library
(`libonoma_bridge.<dylib|so|dll>`). At runtime the plugin loads it via:

```lua
package.loadlib(path, 'luaopen_onoma_bridge')
```

from `<plugin>/bridge/target/release/libonoma_bridge.<ext>`.

Normally (lazy.nvim + `version = '*'`) the plugin downloads the prebuilt binary
from its GitHub release into that path. That does NOT work here because Nix
builds the plugin into the read-only store — the runtime download can't write
there. Building from source (`cargo build`) is possible but heavyweight.

## Solution
Fetch the prebuilt release library and place it at the expected path via an
overlay: `nix/overlays/onoma.nix`. It `overrideAttrs` the plugin from
`plugins.overlay` (`prev.neovimPlugins.onoma`) and, in `postInstall`:
- copies the fetched lib to `bridge/target/release/libonoma_bridge.<ext>`
- writes `bridge/target/release/tag` with the release tag (satisfies the
  plugin's version check so it won't attempt a download).

The library is a Lua C module exporting `luaopen_onoma_bridge` — verified with
`nm -gU`.

### Release asset → Nix system mapping
- aarch64-darwin  -> aarch64-apple-darwin.dylib
- x86_64-darwin   -> x86_64-apple-darwin.dylib
- aarch64-linux   -> aarch64-unknown-linux-gnu.so   (nixpkgs is glibc, so `gnu`)
- x86_64-linux    -> x86_64-unknown-linux-gnu.so

## Bumping the version
1. Edit `release` in `nix/overlays/onoma.nix` (e.g. `v0.0.26`).
2. Refresh each hash:
   ```sh
   TAG=v0.0.26
   BASE="https://github.com/ryanmab/onoma.nvim/releases/download/$TAG"
   for a in aarch64-apple-darwin.dylib x86_64-apple-darwin.dylib \
            aarch64-unknown-linux-gnu.so x86_64-unknown-linux-gnu.so; do
     echo -n "$a -> "; nix store prefetch-file --json "$BASE/$a" \
       | python3 -c "import sys,json;print(json.load(sys.stdin)['hash'])"
   done
   ```
3. Also run `just update_plugins` if the pinned plugin source (flake input)
   should track the same release; the overlay's `release` var only controls the
   fetched binary, independent of the plugin Lua source rev.

## Verify
```sh
NVIM=$(nix build --no-link --print-out-paths '.#nvim')
"$NVIM/bin/nvim" --headless \
  -c "lua local b=require('bridge.utils').load_bridge(); print('BRIDGE_LOADED='..tostring(b~=nil))" \
  -c "qa!"
# expect: BRIDGE_LOADED=true
```

## Lua config
Already wired in `lua/plugins/core/snacks.lua`:
```lua
plugin("onoma")
  :event("DeferredUIEnter")
  :dep_on(snacks)
  :opts({ picker = { "snacks" } })   -- calls require("onoma").setup(...)
  :keymaps({ k:map("n", "<leader>fs", k:require("snacks.picker").get_symbols(), "find symbols") })
```

## Note
nixpkgs also ships a properly-packaged `onoma.nvim` (with the bridge built), so
an alternative is to use `pkgs.vimPlugins.onoma-nvim` directly instead of the
flake-input + overlay approach. We kept the flake-input approach for
consistency with the rest of the repo's plugin management.
