{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
    ]
    ++ (with nvim_pkgs; [
      copilot
      codecompanion
      copilot-lualine
    ]);
}
