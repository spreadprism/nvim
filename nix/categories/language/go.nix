{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    unstable.gopls
    unstable.delve
    unstable.golangci-lint
    unstable.gofumpt
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
