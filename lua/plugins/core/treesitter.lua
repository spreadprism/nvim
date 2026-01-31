plugin("nvim-treesitter"):event("DeferredUIEnter"):opts(false):after(function()
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		indent = {
			enable = true,
			disable = { "nix" },
		},
	})
end)

-- TODO: nvim-treesitter-endwise
-- TODO: nvim-treesitter-textobjects
-- TODO: treesitter-context
