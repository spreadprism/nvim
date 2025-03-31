{pkgs, ...}: let
  vimPlugins = pkgs.vimPlugins;
in {
  optionalPlugins = with vimPlugins; [
    neogit
    diffview-nvim
    gitsigns-nvim
  ];
}
