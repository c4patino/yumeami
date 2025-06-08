{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    snowfall-lib = {
      url = "github:songpola/snowfallorg-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:c4patino/nixvim";
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
        ];
      };

      snowfall = {
        namespace = "yumeami";
        meta = {
          name = "yumeami";
          title = "yumeami";
        };
      };
    };
}
