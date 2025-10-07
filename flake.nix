{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    devshell.url = "github:numtide/devshell";
    impermanence.url = "github:nix-community/impermanence";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    stylix.url = "github:danth/stylix";
    walker.url = "github:abenz1267/walker";
    xremap.url = "github:xremap/nix-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:songpola/snowfallorg-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yumevim-nix = {
      url = "github:c4patino/yumevim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:c4patino/dotfiles";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
        cudaSupport = true;
        permittedInsecurePackages = [
          "mono-5.20.1.34"
        ];
      };

      snowfall = {
        namespace = "yumeami";
        meta = {
          name = "yumeami";
          title = "yumeami";
        };
      };

      alias = {
        shells.default = "yumeami";
        templates.default = "devshell";
      };

      outputs-builder = channels: let
        treefmtConfig = {...}: {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            stylua.enable = true;
          };
          settings = {
            global.excludes = [
              "inputs/**"
            ];
          };
        };

        treefmtEval = inputs.treefmt-nix.lib.evalModule (channels.nixpkgs) (treefmtConfig {pkgs = channels.nixpkgs;});
      in {
        formatter = treefmtEval.config.build.wrapper;
      };
    };
}
