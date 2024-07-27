{ inputs, pkgs, ... }: {
    imports = [
        ./stylix.nix

        ../../programs
        ../../wayland

        inputs.sops-nix.homeManagerModules.sops
    ];

    home.packages = with pkgs; [
        curl
        wget
        xclip
        sops
        git-agecrypt
    ];

    home.file."dotfiles/".source = inputs.nixos-config;

    sops = {
        defaultSopsFile = inputs.dotfiles + "/secrets/sops/secrets.yaml" ;
        defaultSopsFormat = "yaml";
        age = {
            keyFile = "/home/nixos/.config/sops/age/keys.txt";
            generateKey = true;
        };

        secrets = {
        };
    };

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
