# This file defines overlays
{inputs, ...}: {
  codelldb = import ./codelldb.nix;
  java-debug = import ./java.nix;
  commit-lsp = import ./commit-lsp.nix;
  unstable-packages = import ./unstable.nix {inherit inputs;};
}
