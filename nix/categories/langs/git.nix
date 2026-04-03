{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    commit-lsp
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
