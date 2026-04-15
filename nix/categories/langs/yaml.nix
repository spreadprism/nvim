{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    yaml-language-server
  ];
  optionalPlugins = with nvim_pkgs; [
    yaml-companion
  ];
}
