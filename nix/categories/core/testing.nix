{vim_pkgs, ...}: {
  startupPlugins = with vim_pkgs; [
    nvim-nio
  ];
  optionalPlugins = with vim_pkgs; [
    neotest
  ];
}
