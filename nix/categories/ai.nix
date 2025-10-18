{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    claude-code
    opencode
  ];
  optionalPlugins = with vim_pkgs;
    [
    ]
    ++ (with nvim_pkgs; [
      opencode
      copilot
      copilot-lualine
    ]);
}
