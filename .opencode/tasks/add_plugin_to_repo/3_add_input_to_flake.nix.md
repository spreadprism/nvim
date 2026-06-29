# Step 3: Add input to flake.nix

Inside `nix/plugins/flake.nix`, add the plugin as an input using the template:

```
    "plugin-name" = {
      url = "github:repo-url";
      flake = false;
    };
```

Insert it into the inputs section.