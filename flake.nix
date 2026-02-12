{
  description = "A tool to generate PEP 561 typing stubs for PyGObject";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {config, self', inputs', pkgs, system, ...}: {
        packages = {
          gengir = pkgs.rustPlatform.buildRustPackage {
            pname = "gengir";
            version = "1.1.0";
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
            nativeBuildInputs = with pkgs; [pkg-config];
            buildInputs = with pkgs; [libxml2];
          };
          default = config.packages.gengir;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [config.packages.gengir];
          packages = with pkgs; [cargo rustc rustfmt clippy];
        };
      };
    };
}
