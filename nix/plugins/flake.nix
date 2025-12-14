{
  description = "Neovim plugins";
  inputs = {
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
  };
  outputs = {nixpkgs, ...} @ inputs: let
    lib = nixpkgs.lib;
    inherit (lib) filterAttrs attrNames listToAttrs nameValuePair;
    pluginSrcs = filterAttrs (n: _: n != "nixpkgs") inputs; # every input except nixpkgs

    # Get relative paths from base directory
    getRelativePaths = baseDir: let
      baseDirStr = toString baseDir;
      allFiles = lib.filesystem.listFilesRecursive baseDir;
      stripBasePath = path: let
        pathStr = toString path;
        # Remove base directory and leading slash
        relPath = lib.removePrefix (baseDirStr + "/") pathStr;
        # Remove .lua extension
        withoutExt = lib.removeSuffix ".lua" relPath;
        # Replace / with .
        dotPath = builtins.replaceStrings ["/"] ["."] withoutExt;

        # Adds plugins.
        withPrefix = "plugins.${dotPath}";
      in
        withPrefix;
    in
      map stripBasePath allFiles;
  in {
    paths = getRelativePaths ../../lua/plugins;
    overlay = self: super: let
      inherit (super.vimUtils) buildVimPlugin;
      plugins = attrNames pluginSrcs;
      buildPlug = name:
        buildVimPlugin {
          pname = name; # no prefix stripping
          src = builtins.getAttr name pluginSrcs;
          doCheck = false;
          version = "master";
        };
    in {
      neovimPlugins =
        (super.neovimPlugins or {})
        // (listToAttrs (map (p: nameValuePair p (buildPlug p)) plugins));
    };
  };
}
