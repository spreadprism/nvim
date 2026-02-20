{
  pkgs,
  vim_pkgs,
  ...
}: let
in {
  lspsAndRuntimeDeps = with pkgs; [
    terraform
    terraform-ls
    unstable.tofu-ls
    unstable.tflint
  ];
  optionalPlugins = with vim_pkgs; [
    (nvim-treesitter.withPlugins (
      plugins:
        with plugins; [
          terraform
          hcl
        ]
    ))
  ];
}
