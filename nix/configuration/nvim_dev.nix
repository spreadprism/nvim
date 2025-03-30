{ nixpkgs, ... }:
let
  inherit(nixpkgs.lib) recursiveUpdate;
  base = import ./nvim.nix { inherit nixpkgs; };
in recursiveUpdate base {
    categories = {
      go = true;
    };
}
