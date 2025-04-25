{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
      codecompanion-nvim
    ]
    ++ (with nvim_pkgs; [
      copilot
      copilot-lualine
    ]);
}
