{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    gopls
    delve
    golangci-lint
    gofumpt
  ];
  optionalPlugins = with nvim_pkgs; [
    neotest-golang
  ];
}
