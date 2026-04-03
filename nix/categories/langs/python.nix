{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    ty
    uv
    ruff
  ];
  optionalPlugins = with nvim_pkgs; [
    venv-selector
    dap-python
  ];
}
