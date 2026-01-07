require("nixCats.nixcats").setup({
	non_nix_value = true,
})

_G.nixcats = require("nixCats")
_G.DEV = nixcats.cats.dev
