{
  pkgs,
  nvim_pkgs,
  ...
}: {
  startupPlugins = with nvim_pkgs; [
    nui
  ];
  optionalPlugins = with nvim_pkgs; [
    neogit
    gitsigns
    pkgs.vimPlugins.codediff-nvim
  ];
}
