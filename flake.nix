{
  description = "My neovim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plugins = {
      url = "path:nix/plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    nixCats,
    plugins,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = "${./.}";
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSystem = utils.eachSystem supportedSystems;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    extra_pkg_config = {
      allowUnfree = true;
    };
    overlays = let
      overlayFiles = builtins.attrNames (builtins.readDir ./nix/overlays);
      loadOverlay = file: import (./nix/overlays + "/${file}");
    in
      builtins.listToAttrs (
        builtins.map (file: {
          name = builtins.replaceStrings [".nix"] [""] file;
          value = loadOverlay file;
        })
        overlayFiles
      );
    dependencyOverlays =
      [
        plugins.overlay
      ]
      ++ builtins.attrValues overlays;
    categoryDefinitions = {pkgs, ...}: let
      cats = import ./nix/categories.nix {
        inherit pkgs inputs;
        lib = pkgs.lib;
      };
      attrOrEmpty = attr:
        if builtins.hasAttr attr cats
        then cats."${attr}"
        else {};
    in {
      lspsAndRuntimeDeps = attrOrEmpty "lspsAndRuntimeDeps";
      startupPlugins = attrOrEmpty "startupPlugins";
      optionalPlugins = attrOrEmpty "optionalPlugins";
    };
    base_settings = {pkgs, ...}: {
      wrapRc = true;
      neovim-unwrapped = inputs.neovim.packages.${pkgs.system}.neovim; # BUG: blink.cmp
    };
    base_categories = {pkgs, ...}: {
      core = true;
      langs = true; # enable every languages
      ai = true;
      requests = true;
      plugins = {
        paths = plugins.paths;
        names = plugins.names;
      };
      overlays = pkgs.overlayMeta or {};
    };
    base_extra = {pkgs, ...}: {
      nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
    };

    packageDefinitions = {
      nvim = {...} @ misc: {
        settings =
          base_settings misc
          // {
          };
        categories =
          base_categories misc
          // {
          };
        extra = base_extra misc // {};
      };
      nvim_dev = {...} @ misc: {
        settings =
          base_settings misc
          // {
          };
        categories =
          base_categories misc
          // {
            langs = true;
            remote = true;
            tmux = true;
            dev = true;
          };
        extra = base_extra misc // {};
      };
    };
    defaultPackageName = "nvim";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      pkgs = import nixpkgs {
        inherit system;
        config = extra_pkg_config;
        overlays = dependencyOverlays;
      };
    in {
      packages = utils.mkAllWithDefault defaultPackage;

      # Expose overlay metadata
      overlayMeta = pkgs.overlayMeta or {};

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = "nvim_dev";
          packages = [(nixCatsBuilder "nvim_dev")];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
