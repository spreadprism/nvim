if not nixCats("language.nix") then
	return
end
lsp("nixd"):settings({
	nixd = {
		nixpkgs = {
			expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
		},
		formatting = {
			command = { "nixfmt" },
		},
		options = {
			nixos = {
				expr = nixCats.extra("nixdExtras.nixos_options"),
			},
			["home-manager"] = {
				expr = nixCats.extra("nixdExtras.home_manager_options"),
			},
		},
		diagnostic = {
			suppress = {
				"sema-escaping-with",
			},
		},
	},
})
formatter("nix", "alejandra")
