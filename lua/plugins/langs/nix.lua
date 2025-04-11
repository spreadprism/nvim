lsp("nixd"):ft("nix"):root_markers(".git"):settings({
	nixd = {
		expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
	},
	options = {
		nixos = {
			expr = nixCats.extra("nixdExtras.nixos_options"),
		},
		["home-manager"] = {
			expr = nixCats.extra("nixdExtras.home_manager_options"),
		},
	},
	formatting = {
		command = { "nixfmt" },
	},
	diagnostic = {
		suppress = {
			"sema-escaping-with",
		},
	},
})
formatter("nix", "alejandra")
