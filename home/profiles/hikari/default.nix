{ inputs, ... }: {
    imports = [
        ./stylix.nix
    ];

    home.file."dotfiles/".source = inputs.nixos-config;

    home = {
        username = "nixos";
        homeDirectory = "/home/nixos";
        stateVersion = "23.11";
        sessionVariables = {
            FLAKE = "/home/nixos/dotfiles";
        };
    };

    wayland.windowManager.hyprland.settings.monitor = [
        ", preferred, auto, 1"
    ];
} 
