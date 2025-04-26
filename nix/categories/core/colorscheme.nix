{vim_pkgs, ...}: {
  startupPlugins = with vim_pkgs; [
    tokyonight-nvim
    transparent-nvim
  ];
}
