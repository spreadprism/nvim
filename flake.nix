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
    "plugins-copilot-lualine" = {
      url = "github:AndreM222/copilot-lualine";
      flake = false;
    };
    "plugins-lualine-nvim" = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    "plugins-kulala" = {
      url = "github:spreadprism/kulala.nvim";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixCats,
    neovim-nightly-overlay,
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
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      name,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        core = with pkgs; [
          ripgrep
          fd
          lua-language-server
          vscode-langservers-extracted
          stylua
          nixd
          alejandra
        ];
        requests = with pkgs; [
          curl
          grpcurl
          jq
          libxml2
        ];
        go = with pkgs; [
          gopls
          delve
          golangci-lint
        ];
        proto = with pkgs; [
          buf
        ];
      };
      startupPlugins = rec {
        debugging = with pkgs.vimPlugins; [
          nvim-nio
        ];
        testing = debugging;
        tmux = with pkgs.vimPlugins; [
          vim-tmux-navigator
        ];
        ai = with pkgs.neovimPlugins; [
          copilot-lualine
        ];
        core = with pkgs.neovimPlugins;
          [
            oil-vcs-status
            lualine-nvim
          ]
          ++ (with pkgs.vimPlugins; [
            lze
            mini-pairs
            lzextras
            plenary-nvim
            promise-async
            oil-nvim
            nvim-web-devicons
            tokyonight-nvim
            transparent-nvim
            which-key-nvim
            overseer-nvim
          ]);
      };
      optionalPlugins = {
        ai = with pkgs.vimPlugins;
          [
            codecompanion-nvim
          ]
          ++ (with pkgs.neovimPlugins; [
            copilot
          ]);
        debugging = with pkgs.vimPlugins; [
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
        ];
        requests = with pkgs.vimPlugins;
          [
            (nvim-treesitter.withPlugins (
              plugins:
                with plugins; [
                  http
                  html
                  javascript
                  typescript
                ]
            ))
          ]
          ++ (with pkgs.neovimPlugins; [
            kulala
          ]);
        workspace = with pkgs.neovimPlugins; [
          exrc
        ];
        testing = with pkgs.vimPlugins; [
          neotest
        ];
        git = with pkgs.vimPlugins; [
          neogit
          diffview-nvim
          gitsigns-nvim
        ];
        go = with pkgs.vimPlugins; [
          nvim-dap-go
          neotest-golang
          (nvim-treesitter.withPlugins (
            plugins:
              with plugins; [
                go
                gowork
                gomod
                gosum
                gotmpl
              ]
          ))
        ];
        proto = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (
            plugins:
              with plugins; [
                proto
              ]
          ))
        ];
        remote = with pkgs.vimPlugins; [
          nvim-osc52
        ];
        core = with pkgs.vimPlugins;
          [
            nvim-osc52
            neoscroll-nvim
            nvim-lspconfig
            nvim-treesitter-textobjects
            nvim-treesitter-endwise
            (nvim-treesitter.withPlugins (
              plugins:
                with plugins; [
                  nix
                  lua
                  luadoc
                  bash
                  make
                  json
                  toml
                  yaml
                  markdown
                  markdown_inline
                  regex
                  vim
                  vimdoc
                  proto
                ]
            ))
            vim-startuptime
            nvim-notify
            noice-nvim
            dressing-nvim
            todo-comments-nvim
            mini-indentscope
            nvim-highlight-colors
            smart-splits-nvim
            nvim-ts-autotag
            mini-ai
            mini-surround
            mini-move
            nvim-surround
            comment-nvim
            blink-cmp
            lazydev-nvim
            neoconf-nvim
            hover-nvim
            fidget-nvim
            telescope-nvim
            telescope-zf-native-nvim
            telescope-fzf-native-nvim
            telescope-dap-nvim
            hop-nvim
            nvim-lint
            conform-nvim
            tabout-nvim
            nvim-ufo
            luasnip
            grug-far-nvim
            trouble-nvim
          ]
          ++ (with pkgs.neovimPlugins; [
            harpoon
            esqueleto
          ]);
      };
      sharedLibraries = {};
      environmentVariables = {};
      extraWrapperArgs = {};
    };
    base_settings = {pkgs, ...} @ misc: {
      wrapRc = true;
      viAlias = false;
      vimAlias = false;
    };
    base_categories = {pkgs, ...} @ misc: {
      core = true;
      ai = true;
      git = true;
      debugging = true;
      testing = true;
      tmux = true;
      workspace = true;
      requests = true;
    };
    base_extra = {pkgs, ...} @ misc: {
      nixpkgs = ''import ${pkgs.path} {}'';
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
      };
      nvim_dev = {pkgs, ...} @ misc: {
        settings =
          base_settings misc
          // {
          };
        categories =
          base_categories misc
          // {
            go = true;
            requests = true;
            proto = true;
            remote = true;
          };
      };
      nvim_minimal = {pkgs, ...} @ misc: {
        settings =
          base_settings misc
          // {
          };
        categories = {
          core = true;
        };
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
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
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
