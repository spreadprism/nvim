{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    unstable.lua-language-server
  ];
  optionalPlugins = with nvim_pkgs; [
    lazydev
  ];
}
