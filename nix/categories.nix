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
      builtins.listToAttrs (builtins.map (
          path: let
            key = pathToAttrs path;
            splitKey = lib.strings.splitString "." key;
            value = pathValue path;
            buildNestedAttr = parts: val:
              if builtins.length parts == builtins.length splitKey
              then {
                name = builtins.head parts;
                value =
                  if builtins.length parts == 1
                  then
                    if builtins.hasAttr attr value
                    then value."${attr}"
                    else []
                  else buildNestedAttr (builtins.tail parts) val;
              }
              else if builtins.length parts == 1
              then {
                ${builtins.head parts} =
                  if builtins.hasAttr attr value
                  then value."${attr}"
                  else null;
              }
              else {
                ${builtins.head parts} = value;
              };
          in
            buildNestedAttr splitKey value
        )
        nix_files)
  )
