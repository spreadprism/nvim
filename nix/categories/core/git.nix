{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
      neogit
      diffview-nvim
      gitsigns-nvim
      mini-diff
      telescope-git-conflicts-nvim
    ]
    ++ (with nvim_pkgs; [
      git-conflict
    ]);
}
