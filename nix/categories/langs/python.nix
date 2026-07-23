{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    ty
    basedpyright
    uv
    ruff
  ];
  optionalPlugins = with nvim_pkgs; [
    venv-selector
    dap-python
  ];
}
