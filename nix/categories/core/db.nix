{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
      nui-nvim
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
            sql
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      nvim-dbee
      cmp-dbee
    ]);
}
