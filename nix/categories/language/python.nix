{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    basedpyright
    ruff
    fd
  ];
  optionalPlugins = with vim_pkgs;
    [
      nvim-dap-python
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
            python
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      venv-selector
    ]);
}
