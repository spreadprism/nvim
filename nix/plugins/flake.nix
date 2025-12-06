{
  description = "Neovim plugins";
  inputs = {
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
  };
  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs.lib) filterAttrs attrNames listToAttrs nameValuePair;
    pluginSrcs = filterAttrs (n: _: n != "nixpkgs") inputs; # every input except nixpkgs

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
  in {inherit overlay pluginSrcs;};
}
