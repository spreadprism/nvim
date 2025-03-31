{nixpkgs, ...}: let
  inherit (nixpkgs.lib) genAttrs recursiveUpdate;
  configurations = builtins.map (name: builtins.substring 0 (builtins.stringLength name - 4) name) (builtins.attrNames (builtins.readDir ./configuration));
  forEachConfiguration = genAttrs configurations;
in
  forEachConfiguration (configuration: {pkgs, ...}: recursiveUpdate (import ./configuration/${configuration}.nix {inherit nixpkgs;}) {categories.core = true;})
