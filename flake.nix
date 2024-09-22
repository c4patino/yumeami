{
    description = "snowflake";

    outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
            inputs.devshell.flakeModule

            ./system/hosts
            ./home/profiles
        ];

        systems = ["x86_64-linux"];

        perSystem = { config, pkgs, system, ... }:
		let
			pkgs = import inputs.nixpkgs {
				inherit system;
				config = {
					allowUnfree = true;
					cudaSupport = true;
				};
			};
		in
        {
            devShells = {
                python311-dev = (import ./envs/python311.nix {inherit pkgs;});
                python312-dev = (import ./envs/python312.nix {inherit pkgs;});
                c-dev = (import ./envs/c.nix {inherit pkgs;});
                cpp-dev = (import ./envs/cpp.nix {inherit pkgs;});
            };
        };
    };

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        devshell.url = "github:numtide/devshell";

        hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
        yazi.url = "github:sxyazi/yazi";
        stylix.url = "github:danth/stylix";
        eww.url = "github:elkowar/eww";
        anyrun.url = "github:Kirottu/anyrun";
        impermanence.url = "github:nix-community/impermanence";
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

        neovim-config = {
            url = "github:C4theBomb/neovim";
            flake = false;
        };
        nixvim-config.url = "github:C4theBomb/nixvim";
        dotfiles = {
            url = "github:C4theBomb/dotfiles";
            flake = false;
        };
        nixos-config = {
            url = "github:C4theBomb/nixos-config";
            flake = false;
        };
    };
}
