{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell.url = "github:numtide/devshell";
    impermanence.url = "github:nix-community/impermanence";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    stylix.url = "github:danth/stylix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    walker.url = "github:abenz1267/walker";
    xremap.url = "github:xremap/nix-flake";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "git+https://git.cpatino.com/c4patino/snowfallorg-lib?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yumevim-nix = {
      url = "git+https://git.cpatino.com/c4patino/yumevim-nix?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dotfiles = {
      url = "git+https://git.cpatino.com/c4patino/dotfiles?ref=main";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
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

      templates = {
        devenv.description = "devenv development environment";
        devshell.description = "nixpkgs mkshell development environment";
      };

      outputs-builder = channels: let
        treefmtConfig = {...}: {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            keep-sorted.enable = true;
            stylua.enable = true;
            terraform.enable = true;
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
