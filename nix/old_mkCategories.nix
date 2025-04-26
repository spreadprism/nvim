{
  pkgs,
  lib,
  ...
}: let
  base_path = builtins.toString (./. + "/categories");
  paths = builtins.filter (x: lib.hasSuffix ".nix" x) (lib.filesystem.listFilesRecursive ./categories);
  pathToAttrs = path: lib.strings.removePrefix "." (builtins.replaceStrings ["/" "."] ["." ""] (lib.strings.removePrefix (base_path + "/") (lib.strings.removeSuffix ".nix" (builtins.toString path))));
  cat_attrs = builtins.listToAttrs (builtins.map (path: let
    value = import path {inherit pkgs;};
    attrs = builtins.attrNames value;
    key = pathToAttrs path;
    splitKey = lib.strings.splitString "." ("optionalPlugins." + key);
    buildNestedAttr = parts: val:
      if builtins.length parts == builtins.length splitKey
      then {
        name = builtins.head parts;
        value = buildNestedAttr (builtins.tail parts) val;
      }
      else {
        ${builtins.head parts} = value;
      };
  in
    buildNestedAttr splitKey value)
  paths);
in {
  lspsAndRuntimeDeps = {
  };
}
