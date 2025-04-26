{
  pkgs,
  lib,
  ...
}: let
  base_path = ./categories;
  all_files = lib.filesystem.listFilesRecursive base_path;
  nix_files = builtins.filter (x: lib.hasSuffix ".nix" x) all_files;
  pathValue = path:
    import path {
      inherit pkgs;
      vim_pkgs = pkgs.vimPlugins;
      nvim_pkgs = pkgs.neovimPlugins;
    };
  pathValueAttr = path: attr: let
    val = pathValue path;
  in
    if builtins.hasAttr attr val
    then val."${attr}"
    else [];
  attrs = lib.unique (builtins.concatLists (builtins.map (p: builtins.attrNames (pathValue p)) nix_files));

  forEachAttrs = lib.genAttrs attrs;
  pathToAttrs = path:
    lib.strings.removePrefix "." (
      builtins.replaceStrings ["/" "."] ["." ""] (
        lib.strings.removePrefix (builtins.toString base_path + "/") (
          lib.strings.removeSuffix ".nix" (builtins.toString path)
        )
      )
    );
in
  forEachAttrs (
    attr:
      lib.lists.foldl
      lib.attrsets.recursiveUpdate
      {}
      (
        builtins.map (
          path: let
            splitKey = lib.strings.splitString "." (pathToAttrs path);
            value = pathValueAttr path attr;
          in
            lib.attrsets.setAttrByPath splitKey value
        )
        nix_files
      )
  )
