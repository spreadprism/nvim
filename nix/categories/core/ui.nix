{nvim_pkgs, ...}: {
  optionalPlugins = with nvim_pkgs; [
    heirline
    dropbar
    nvim-web-devicons
  ];
}
