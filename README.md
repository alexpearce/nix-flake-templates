# Nix flake templates

This repository bundles together the [Nix flake templates][templates] I use to quickly create cross-platform, reproducible development environments.
It requires [Nix][nix] installation, for example as provided by the [Determinate Systems installer][nix-installer].

To list available templates:

```
nix flake show github:alexpearce/nix-flake-templates
```

To create a new directory from a template, for example the `elixir-phoenix` template:

```
nix flake new --template github:alexpearce/nix-flake-templates <directory name>
```

[templates]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-init.html#template-definitions
[nix]: https://nixos.org/
[nix-installer]: https://github.com/DeterminateSystems/nix-installer