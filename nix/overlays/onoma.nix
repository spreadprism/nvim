# source: 100% llm, I have no idea how this works, but it does
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
