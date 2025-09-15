{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = {
    flake-utils,
    nixpkgs,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        treefmtConfig = {...}: {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        };

        treefmtEval = treefmt-nix.lib.evalModule pkgs (treefmtConfig {inherit pkgs;});
      in {
        formatter = treefmtEval.config.build.wrapper;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
          ];

          buildInputs = with pkgs; [
          ];

          packages = with pkgs; [
          ];

          shellHook = ''
          '';
        };
      }
    );
}
