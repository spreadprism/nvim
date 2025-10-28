# nvim

This repository contains my personal Neovim configuration, managed with [Nix](https://nixos.org/) and [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim). It provides a highly customized and modular development environment with extensive language support, UI enhancements, and various developer tools.

## Features

*   **Nix-managed**: Fully declarative and reproducible Neovim environment using Nix flakes.
*   **Modular Configuration**: Organized Lua files for easy management and customization of options, keymaps, plugins, and language-specific settings.
*   **Extensive Plugin Ecosystem**:
    *   **Core Editing**: `nvim-treesitter`, `nvim-cmp` (completion), `telescope.nvim` (fuzzy finder), `harpoon` (quick file navigation), `undotree` (visual undo history).
    *   **Language Server Protocol (LSP)**: Comprehensive LSP support for various languages, providing features like auto-completion, diagnostics, go-to-definition, and refactoring.
    *   **Debugging (DAP)**: Integrated Debug Adapter Protocol support with `nvim-dap` and `nvim-dap-ui`.
    *   **Linting & Formatting**: `nvim-lint` and `null-ls.nvim` for code quality and automatic formatting.
    *   **Git Integration**: `neogit` for a Magit-like Git experience within Neovim.
    *   **UI Enhancements**: `lualine.nvim` (status line), `nvim-web-devicons` (file icons), `noice.nvim` (better UI messages).
    *   **Productivity**: `overseer.nvim` (task runner), `oil.nvim` (file explorer), `tmux-navigator` (seamless Tmux pane navigation).
    *   **AI Integration**: `copilot.lua` for AI-powered code suggestions.
    *   **Database**: `nvim-dbee` for database interaction.
*   **Language Support**: Pre-configured settings and LSP for a wide array of programming languages (e.g., Lua, Nix, Go, Python, Rust, C++, Java, Docker, Terraform, YAML, Markdown, JSON, Just, Proto, Helm).
*   **Dev Tools**: Integration with various development tools and utilities.

## Installation

This configuration uses [Nix flakes](https://nixos.wiki/wiki/Flakes) for a declarative setup.

1.  **Install Nix**: If you don't have Nix installed, follow the instructions on the [NixOS website](https://nixos.org/download.html). Ensure you have flakes enabled.

2.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/nvim.git ~/.config/nvim
    cd ~/.config/nvim
    ```
    *(Note: Replace `your-username` with your actual GitHub username if you've forked it, or adjust the clone URL as necessary.)*

3.  **Build and run Neovim**:
    You can build and run the default Neovim configuration using:
    ```bash
    nix run .#nvim
    ```
    For a development-focused environment with more tools enabled:
    ```bash
    nix run .#nvim_dev
    ```
    To enter a development shell with Neovim and its dependencies available:
    ```bash
    nix develop
    ```
    Then, you can run `nvim` directly from within the shell.

4.  **Integrate with Home Manager/NixOS (Optional)**:
    You can integrate this configuration into your `home-manager` or `nixos` configuration by adding it as an input and using the provided modules. Refer to `flake.nix` for `nixosModules` and `homeModules` outputs.

## Usage

Once installed, simply open Neovim:

```bash
nvim
```

Explore the `lua/keymap.lua` file for a comprehensive list of keybindings.

## Structure

The repository is structured as follows:

*   `flake.nix`: Defines the Nix flake for the Neovim configuration.
*   `init.lua`: The main entry point for Neovim, loading other configuration files.
*   `lua/`: Contains the core Lua configuration files.
    *   `lua/internal/`: Internal helper functions and modules.
    *   `lua/plugins/`: Plugin definitions and their configurations.
    *   `lua/language/`: Language-specific configurations (LSP, treesitter, etc.).
    *   `lua/lualine/`: Custom components and sections for `lualine.nvim`.
    *   `lua/icons/`: Icon configurations.
    *   `lua/snippets/`: Custom snippet definitions.
    *   `lua/templates/`: File templates.
*   `nix/`: Nix-specific configuration files.
    *   `nix/categories/`: Defines plugin categories for `nixCats-nvim`.
    *   `nix/overlays/`: Nix overlays for packages.
*   `rules/`: Ast-grep rules.

## Contributing

Feel free to fork this repository and adapt it to your needs. If you find any issues or have suggestions, please open an issue or submit a pull request.
