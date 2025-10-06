{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
      diffview-nvim
      gitsigns-nvim
      mini-diff
      telescope-git-conflicts-nvim
    ]
    ++ (with nvim_pkgs; [
      git-conflict
      neogit
    ]);
}
