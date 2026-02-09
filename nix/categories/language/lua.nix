{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    unstable.lua-language-server
    unstable.stylua
  ];
  optionalPlugins = with nvim_pkgs; [
    lazydev
  ];
}
