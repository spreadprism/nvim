{
  description = "Neovim plugins";
  inputs = {
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    heirline = {
      url = "github:rebelot/heirline.nvim";
      flake = false;
    };
    heirline-components = {
      url = "github:Zeioth/heirline-components.nvim";
      flake = false;
    };
    oil = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    oil-vcs = {
      url = "github:spreadprism/oil-vcs";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    tmux-navigation = {
      url = "github:christoomey/vim-tmux-navigator";
      flake = false;
    };
    # neogit = {
    #   url = "github:NeogitOrg/neogit";
    #   flake = false;
    # };
    neogit = {
      url = "github:sotte/neogit?ref=support-vscode-diff";
      flake = false;
    };
    gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nui = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    lazydev = {
      url = "github:folke/lazydev.nvim";
      flake = false;
    };
    hop = {
      url = "github:smoka7/hop.nvim";
      flake = false;
    };
    blink-compat = {
      url = "github:saghen/blink.compat";
      flake = false;
    };
    blink-cmp-git = {
      url = "github:Kaiser-Yang/blink-cmp-git";
      flake = false;
    };
    blink-cmp-conventional-commits = {
      url = "github:disrupted/blink-cmp-conventional-commits";
      flake = false;
    };
    tabout = {
      url = "github:abecodes/tabout.nvim";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    mini-ai = {
      url = "github:nvim-mini/mini.ai";
      flake = false;
    };
    mini-move = {
      url = "github:nvim-mini/mini.move";
      flake = false;
    };
    blame = {
      url = "github:FabijanZulj/blame.nvim";
      flake = false;
    };
    nvim-treesitter-endwise = {
      url = "github:RRethy/nvim-treesitter-endwise";
      flake = false;
    };
    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    conform = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    lint = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    osc52 = {
      url = "github:ojroques/nvim-osc52";
      flake = false;
    };
    smart-paste = {
      url = "github:nemanjamalesija/smart-paste.nvim";
      flake = false;
    };
    treesj = {
      url = "github:Wansmer/treesj";
      flake = false;
    };
    scrollbar = {
      url = "github:petertriho/nvim-scrollbar";
      flake = false;
    };
    undotree = {
      url = "github:jiaoshijie/undotree";
      flake = false;
    };
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
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
    names = attrNames pluginSrcs;
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
