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
    blame
    pkgs.unstable.vimPlugins.codediff-nvim
  ];
}
