# This file defines overlays
{inputs, ...}: {
  codelldb = import ./codelldb.nix;
  java-debug = import ./java.nix;
  unstable-packages = import ./unstable.nix {inherit inputs;};
}
