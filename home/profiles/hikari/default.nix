{ inputs, pkgs, ... }: {
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

    music.enable = false;
    pycharm.enable = false;
    idea.enable = false;
    leetcode.enable = false;
    nvtop.enable = true;
    sms.enable = false;
    libreoffice.enable = false;
    obs.enable = false;
    postman.enable = false;
    google-chrome.enable = false;
    languages.enable = false;

    wayland.windowManager.hyprland.settings.monitor = [
        ", preferred, auto, 1"
    ];
} 
