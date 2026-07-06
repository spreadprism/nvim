# Onoma.nvim ships a Rust "bridge" that it normally downloads as a prebuilt
# dynamic library from its GitHub release at runtime (via curl into
# `bridge/target/release/`). That download can't work here because Nix builds
# the plugin into the read-only store.
#
# Instead of grabbing a release binary, we build the bridge crate from source
# (it lives in the `bridge/` subdirectory of the plugin) and place the resulting
# library where the plugin's loader expects it:
#   <plugin>/bridge/target/release/libonoma_bridge.<ext>
#
# The bridge is built from the *same* source as the `onoma` plugin flake input
# (`neovimPlugins.onoma.src`), so the Lua frontend and the native bridge always
# stay in lockstep. Bump both together with `just update_plugins`.
#
# The bridge is an mlua "module" cdylib linked against LuaJIT: Lua symbols are
# resolved at load time from the host Neovim (macOS `-undefined dynamic_lookup`,
# Linux `-C target-feature=-crt-static` via mlua), so LuaJIT is only needed at
# build time for headers/pkg-config.
final: prev: let
  basePlugin = prev.neovimPlugins.onoma;

  ext =
    if prev.stdenv.hostPlatform.isDarwin
    then "dylib"
    else "so";

  onoma-bridge = prev.rustPlatform.buildRustPackage {
    pname = "onoma-bridge";
    inherit (basePlugin) version;

    # Same source as the plugin flake input; the crate is in `bridge/`.
    src = basePlugin.src;

    # The crate (Cargo.toml + Cargo.lock) lives in the `bridge/` subdirectory.
    # `cargoRoot` points the vendoring/lock hooks at it; `buildAndTestSubdir`
    # makes cargo build/test run there.
    cargoRoot = "bridge";
    buildAndTestSubdir = "bridge";

    cargoLock = {
      lockFile = "${basePlugin.src}/bridge/Cargo.lock";
    };

    nativeBuildInputs = with prev; [
      pkg-config
    ];

    buildInputs = with prev; [
      luajit
    ];

    # mlua "module" cdylibs resolve Lua symbols at load time from the host.
    # On macOS, allow undefined symbols during linking.
    env = prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      RUSTFLAGS = "-C link-arg=-undefined -C link-arg=dynamic_lookup";
    };

    # The crate produces the cdylib; there are no unit tests to run against a
    # host-linked Lua module.
    doCheck = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp target/*/release/libonoma_bridge.${ext} $out/lib/ \
        2>/dev/null || cp bridge/target/release/libonoma_bridge.${ext} $out/lib/
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Rust bridge (native library) for onoma.nvim";
      homepage = "https://github.com/ryanmab/onoma.nvim";
      license = licenses.mit;
      maintainers = [];
    };
  };
in {
  neovimPlugins =
    (prev.neovimPlugins or {})
    // {
      onoma = basePlugin.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            plugindir="$out"
            mkdir -p "$plugindir/bridge/target/release"
            cp ${onoma-bridge}/lib/libonoma_bridge.${ext} \
              "$plugindir/bridge/target/release/libonoma_bridge.${ext}"
          '';
      });
    };

  # Metadata for this overlay
  overlayMeta =
    (prev.overlayMeta or {})
    // {
      onoma = {
      };
    };
}
