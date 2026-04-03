{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    lua-language-server
    stylua
  ];
  optionalPlugins = with nvim_pkgs; [
    lazydev
  ];
}
