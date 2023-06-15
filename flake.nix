{
  description = "A collection of Nix flake templates for defining development environments.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;
      templates = {
        elixir-phoenix = {
          path = ./elixir-phoenix;
          description = "";
          welcomeText = ''
            # Phoenix environment created

            Enable automatic environment activation with direnv:

                direnv enable

            Then bootstrap your new Phoenix project [as usual][phx-bootstrap]:

                mix archive.install hex phx_new
                mix phx.new .

            You can spin up the PostgreSQL server with devenv:

                devenv up

            And then bootstrap the application database:

                mix ecto.create
                mix ecto.migrate

            You can now start the development server as usual:

                mix phx.server

            [phx-bootstrap]: https://hexdocs.pm/phoenix/installation.html
          '';
        };
        empty = {
          path = ./empty;
          description = "";
          welcomeText = ''
            # Empty environment created

            Enable automatic environment activation with direnv:

                direnv enable

            Then modify the development shell's packages to suit your needs.
          '';
        };
      };
    });
}
