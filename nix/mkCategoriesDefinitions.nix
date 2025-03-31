{pkgs, ...} @ packageDef: let
  inherit (pkgs.lib) genAttrs;
  categories = builtins.map (name: builtins.substring 0 (builtins.stringLength name - 4) name) (builtins.attrNames (builtins.readDir ./categories));
  forEachCategory = genAttrs categories;
  forEachAttrs = genAttrs ["lspsAndRuntimeDeps" "startupPlugins" "optionalPlugins" "sharedLibraries" "environmentVariables" "extraWrapperArgs"];
  getImportedAttr = category: attr: let
    imported = import ./categories/${category}.nix {inherit pkgs;};
  in
    if builtins.hasAttr attr imported
    then imported."${attr}"
    else {};
in
  forEachAttrs (attr: forEachCategory (category: getImportedAttr category attr))
