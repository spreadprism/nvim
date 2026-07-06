# Onoma.nvim ships a Rust "bridge" as a prebuilt dynamic library that the
# plugin normally downloads from its GitHub release at runtime (via curl into
# `bridge/target/release/`). That download can't work here because Nix builds
# the plugin into the read-only store.
#
# Instead, we fetch the prebuilt library for the release tag below and place it
# where the plugin's loader expects it:
#   <plugin>/bridge/target/release/libonoma_bridge.<ext>
# We also write the `tag` file so the plugin's version check is satisfied.
#
# To bump the version: update `release`, then update the hashes. Get a hash with:
#   nix store prefetch-file --json \
#     https://github.com/ryanmab/onoma.nvim/releases/download/<tag>/<asset>
final: prev: let
  release = "v0.0.25";

  # Maps Nix system -> { asset = release asset name; hash = sha256; }
  # Release assets: https://github.com/ryanmab/onoma.nvim/releases
  bySystem = {
    "aarch64-darwin" = {
      asset = "aarch64-apple-darwin.dylib";
      hash = "sha256-XO/V1R0VopZnkhoKIeEcdPTLqjbqeCvzz8i83Fd65Vg=";
      ext = "dylib";
    };
    "x86_64-darwin" = {
      asset = "x86_64-apple-darwin.dylib";
      hash = "sha256-jBXMoPJaM0qwMzunrYLNARctko4i6XEsTecFMoEAMc4=";
      ext = "dylib";
    };
    "aarch64-linux" = {
      asset = "aarch64-unknown-linux-gnu.so";
      hash = "sha256-YqDu9SvUEv5RVJeIYEfRglcm9Z1pLpFCXt8VmjB1HHA=";
      ext = "so";
    };
    "x86_64-linux" = {
      asset = "x86_64-unknown-linux-gnu.so";
      hash = "sha256-oOWLJvmKhzYBhnETqRPcfDNgw3LfhFr/aIePoSVUbRM=";
      ext = "so";
    };
  };

  system = prev.stdenv.hostPlatform.system;
  target =
    bySystem.${system}
    or (throw "onoma.nvim: unsupported system '${system}'");

  bridgeLib = prev.fetchurl {
    url = "https://github.com/ryanmab/onoma.nvim/releases/download/${release}/${target.asset}";
    inherit (target) hash;
  };

  basePlugin = prev.neovimPlugins.onoma;
in {
  neovimPlugins =
    (prev.neovimPlugins or {})
    // {
      onoma = basePlugin.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            plugindir="$out"
            if [ -d "$out/share/vim-plugins/onoma" ]; then
              plugindir="$out/share/vim-plugins/onoma"
            fi

            mkdir -p "$plugindir/bridge/target/release"
            cp ${bridgeLib} "$plugindir/bridge/target/release/libonoma_bridge.${target.ext}"

            # Satisfy the plugin's release-tag check so it won't try to download.
            printf '%s' "${release}" > "$plugindir/bridge/target/release/tag"
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
