{vim_pkgs, ...}: {
  startupPlugins = with vim_pkgs; [
  ];
  optionalPlugins = with vim_pkgs; [
    snacks-nvim
  ];
}
