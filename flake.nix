{
  description = "My neovim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = {
    nixpkgs,
    nixCats,
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
    dependencyOverlays = [
      (utils.standardPluginOverlay inputs)
    ];
    # ++ (import ./nix/overlays {inherit inputs;});
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
      neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    };
    base_categories = {...}: {
      core = true;
      language = {
        lua = true;
        nix = true;
      };
      ai = true;
      requests = true;
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
            language = true;
            remote = true;
            devtools = true;
            tmux = true;
          };
        extra = base_extra misc // {};
      };
      nvim_minimal = {...} @ misc: {
        settings =
          base_settings misc
          // {
          };
        categories = {
          core = true;
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
      };
    in {
      packages = utils.mkAllWithDefault defaultPackage;

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
