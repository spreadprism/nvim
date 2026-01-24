{nvim_pkgs, ...}: {
  startupPlugins = with nvim_pkgs; [
    nui
  ];
  optionalPlugins = with nvim_pkgs; [
    heirline
    heirline-components
    dropbar
    nvim-web-devicons
    noice
  ];
}
