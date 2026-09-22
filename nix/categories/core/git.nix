{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    worktrunk
  ];
  startupPlugins = with nvim_pkgs; [
    nui
  ];
  optionalPlugins = with nvim_pkgs; [
    neogit
    gitsigns
    blame
    wt
    pkgs.vimPlugins.codediff-nvim
  ];
}
