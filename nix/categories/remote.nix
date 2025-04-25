{vim_pkgs, ...}: {
  optionalPlugins = with vim_pkgs; [
    nvim-osc52
  ];
}
