{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    helm-ls
  ];
  optionalPlugins = with nvim_pkgs; [
    helm-ls
  ];
}
