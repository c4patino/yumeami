{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";

    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = {
    flake-utils,
    nixpkgs,
    treefmt-nix,
    devenv,
    ...
  } @ inputs:
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

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [
            ({pkgs, ...}: {
              languages = {};

              packages = with pkgs; [];

              processes = {};

              scripts = {};

              services = {};

              tasks = {};
            })
          ];
        };
      }
    );
}
