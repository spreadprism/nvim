{
  pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    unstable.nixd
    unstable.alejandra
  ];
}
