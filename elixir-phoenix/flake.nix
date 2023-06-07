{
  description = "An Elixir Phoenix environment with a PostgreSQL service.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devenv,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      beam = pkgs.beam;
      beamPackages = beam.packagesWith beam.interpreters.erlangR25;
    in {
      formatter = pkgs.nixpkgs-fmt;
      devShells = let
        elixir = beamPackages.elixir_1_14;
        hex = beamPackages.hex;
        postgresql = pkgs.postgresql_15;
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [
            ({pkgs, ...}: {
              packages = (
                with pkgs;
                  [
                    # Elixir.
                    elixir
                    hex
                    beamPackages.elixir-ls
                    # JavaScript.
                    pkgs.nodejs-19_x
                    pkgs.yarn
                  ]
                  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
                    # ExUnit notifications on macOS.
                    terminal-notifier
                    # Support Elixir file system watcher on macOS.
                    darwin.apple_sdk.frameworks.CoreFoundation
                    darwin.apple_sdk.frameworks.CoreServices
                  ])
              );
              # Services can be started in the development shell with `devenv up`.
              # Hitting `ctrl-c` in that shell will stop all running services.
              services = {
                postgres = {
                  enable = true;
                  package = postgresql;
                  # Do not create a database named for the current user.
                  # Our `ecto` tasks will create platform DBs for us.
                  createDatabase = false;
                  listen_addresses = "127.0.0.1";
                  settings = {
                    max_connections = 200;
                    jit = "off";
                  };
                  initialScript = ''
                    CREATE USER postgres SUPERUSER;
                  '';
                };
              };

              enterShell = ''
                # Place Mix/Hex files locally to the project.
                export MIX_HOME=$DEVENV_STATE/mix
                export HEX_HOME=$DEVENV_STATE/hex
                mkdir -p $MIX_HOME
                mkdir -p $HEX_HOME
                # Expose Nix's hex to Mix.
                export MIX_PATH="${hex}/lib/erlang/lib/hex/ebin"
                export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$MIX_HOME/escripts:$PATH
              '';
            })
          ];
        };
      };
    });
}
