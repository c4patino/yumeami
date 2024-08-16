{
    description = "snowflake";

    outputs = inputs: inputs.flake-parts.lib.mkFlake {
        inherit inputs;
    } {
        imports = [
            inputs.pre-commit-hooks.flakeModule
            ./hosts
            ./home/profiles
        ];
        systems = ["x86_64-linux"];
        perSystem = { config, pkgs, ... }: {
            pre-commit = {
                check.enable = true;
                settings = {
                excludes = ["flake.lock"];
                    hooks = {
                        stylua.enable = true;
                        statix.enable = true;
                        alejandra.enable = true;
                        deadnix = {
                            enable = true;
                            excludes = ["overlays.nix"];
                        };
                        prettier = {
                            enable = true;
                            files = "\\.(js|ts|md|json)$";
                            settings = {
                                trailing-comma = "none";
                            };
                        };
                    };
                };
            };
            devShells.default = pkgs.mkShell {
                name = "snowflake";
                shellHook = config.pre-commit.installationScript;
                packages = with pkgs; [
                    git
                    sops
                    alejandra
                    yaml-language-server
                    lua-language-server
                ];
            };
            formatter = pkgs.alejandra;
        };
    };

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

        hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
        yazi.url = "github:sxyazi/yazi";
        stylix.url = "github:danth/stylix";
        eww.url = "github:elkowar/eww";
        anyrun.url = "github:Kirottu/anyrun";
        impermanence.url = "github:nix-community/impermanence";

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
