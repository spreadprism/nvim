{pkgs, ...}: let
  vimPlugins = pkgs.vimPlugins;
in {
  startupPlugins = [
    vimPlugins.vim-tmux-navigator
  ];
}
