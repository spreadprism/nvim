{nvim_pkgs, ...}: {
  optionalPlugins = with nvim_pkgs; [
    tmux-navigation
  ];
}
