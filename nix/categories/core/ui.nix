{nvim_pkgs, ...}: {
  optionalPlugins = with nvim_pkgs; [
    heirline
    heirline-components
    dropbar
    nvim-web-devicons
  ];
}
