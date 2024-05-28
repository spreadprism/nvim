local telescope = plugin("nvim-telescope/telescope.nvim"):tag("0.1.6"):dependencies("nvim-lua/plenary.nvim")
plugin("nvim-telescope/telescope-fzf-native.nvim"):dependencies(telescope):build("make")
