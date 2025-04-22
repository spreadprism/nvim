{nvim_pkgs, ...}: {
  startupPlugins = with nvim_pkgs; [
    profile
  ];
  optionalPlugins = with nvim_pkgs; [
    ex-colors
  ];
}
