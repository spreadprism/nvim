plugin("nvim-neotest/neotest"):event("VeryLazy"):dependencies({
	-- INFO: core
	"nvim-neotest/nvim-nio",
	"nvim-lua/plenary.nvim",
	"antoinemadec/FixCursorHold.nvim",
	"nvim-treesitter/nvim-treesitter",
	-- INFO: Adapters
	"nvim-neotest/neotest-go",
	"nvim-neotest/neotest-python",
	"rouge8/neotest-rust",
	"marilari88/neotest-vitest",
})
