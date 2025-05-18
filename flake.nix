{
  description = "My neovim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    "plugins-oil-vcs-status" = {
      url = "github:SirZenith/oil-vcs-status";
      flake = false;
    };
    "plugins-tokyonight" = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    "plugins-harpoon" = {
      url = "github:ThePrimeagen/harpoon?ref=harpoon2";
      flake = false;
    };
    "plugins-copilot" = {
      url = "github:zbirenbaum/copilot.lua";
      flake = false;
    };
    "plugins-exrc" = {
      url = "github:jedrzejboczar/exrc.nvim";
      flake = false;
    };
    "plugins-esqueleto" = {
      url = "github:cvigilv/esqueleto.nvim";
      flake = false;
    };
    "plugins-lualine-nvim" = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    "plugins-kulala" = {
      url = "github:mistweaverco/kulala.nvim";
      flake = false;
    };
    "plugins-tmux-navigation" = {
      url = "github:christoomey/vim-tmux-navigator";
      flake = false;
    };
    "plugins-ex-colors" = {
      url = "github:aileot/ex-colors.nvim";
      flake = false;
    };
    "plugins-profile" = {
      url = "github:stevearc/profile.nvim";
      flake = false;
    };
    "plugins-easycolor" = {
      url = "github:vi013t/easycolor.nvim";
      flake = false;
    };
    "plugins-render-markdown" = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };
    "plugins-git-conflict" = {
      url = "github:akinsho/git-conflict.nvim";
      flake = false;
    };
    "plugins-blink-compat" = {
      url = "github:Saghen/blink.compat";
      flake = false;
    };
    "plugins-nvim-dbee" = {
      url = "github:kndndrj/nvim-dbee";
      flake = false;
    };
    "plugins-cmp-dbee" = {
      url = "github:MattiasMTS/cmp-dbee";
      flake = false;
    };
    "plugins-dir-telescope" = {
      url = "github:princejoogie/dir-telescope.nvim";
      flake = false;
    };
    "plugins-nvim-lint" = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    "plugins-lspconfig" = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    "plugins-venv-selector" = {
      url = "github:linux-cultist/venv-selector.nvim?ref=regexp";
      flake = false;
    };
    "plugins-lazydev" = {
      url = "github:folke/lazydev.nvim";
      flake = false;
    };
    "plugins-overseer" = {
      url = "github:stevearc/overseer.nvim";
      flake = false;
    };
    "plugins-oil" = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    "plugins-treesitter-context" = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    "plugins-live-command" = {
      url = "github:smjonas/live-command.nvim";
      flake = false;
    };
    "plugins-guess-indent" = {
      url = "github:nmac427/guess-indent.nvim";
      flake = false;
    };
    "plugins-search-replace" = {
      url = "github:roobert/search-replace.nvim";
      flake = false;
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
    dependencyOverlays =
      [
        (utils.standardPluginOverlay inputs)
      ]
      ++ import ./nix/overlays;
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      name,
      ...
    } @ packageDef: let
      cats = import ./nix/categories.nix {
        inherit pkgs;
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
    base_settings = {pkgs, ...} @ misc: {
      wrapRc = true;
    };
    base_categories = {pkgs, ...} @ misc: {
      core = true;
      language = {
        lua = true;
        nix = true;
      };
      ai = true;
      requests = true;
    };
    base_extra = {pkgs, ...} @ misc: {
      nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
    };

    packageDefinitions = {
      nvim = {pkgs, ...} @ misc: {
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
      nvim_dev = {pkgs, ...} @ misc: {
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
      nvim_minimal = {pkgs, ...} @ misc: {
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
