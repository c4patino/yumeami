{
  description = "snowflake";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule

        ./system/hosts
        ./home/profiles
        ./envs
      ];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";

    stylix.url = "github:danth/stylix";
    anyrun.url = "github:Kirottu/anyrun";
    impermanence.url = "github:nix-community/impermanence";
    xremap.url = "github:xremap/nix-flake";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

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

    neovim-config = {
      url = "github:c4patino/neovim";
      flake = false;
    };
    nixvim-config.url = "github:c4patino/nixvim";
    dotfiles = {
      url = "github:c4patino/dotfiles";
      flake = false;
    };
    nixos-config = {
      url = "github:c4patino/nixos-config";
      flake = false;
    };
  };
}
