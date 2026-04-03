{
  pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    nixd
    alejandra
  ];
}
