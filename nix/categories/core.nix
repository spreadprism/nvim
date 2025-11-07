{vim_pkgs, ...}: {
  startupPlugins = with vim_pkgs; [
    lze
    lzextras
    snacks-nvim
  ];
}
