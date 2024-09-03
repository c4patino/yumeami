{ inputs, pkgs, self, ... }: {
    imports = [
        ./stylix.nix
    ];

    sops = {
        defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
        defaultSopsFormat = "yaml";
        age = {
            keyFile = "/home/c4patino/.config/sops/age/keys.txt";
            generateKey = true;
        };

        secrets = {
            github-auth = {};
            github-runner = {};
            github-runner-oasys = {};
        };
    };

    home = {
        username = "c4patino";
        homeDirectory = "/home/c4patino";
        stateVersion = "23.11";
        sessionVariables = {
            FLAKE = "/home/c4patino/dotfiles";
        };
    };

    music.enable = true;
    pycharm.enable = true;
    idea.enable = true;
    leetcode.enable = true;
    nvtop.enable = true;
    sms.enable = true;
    libreoffice.enable = true;
    obsidian.enable = true;
    fiji.enable = true;
    obs.enable = true;
    postman.enable = true;
    google-chrome.enable = true;
    languages.enable = true;

    wayland.windowManager.hyprland.settings.monitor = [
        ", preferred, auto, 1"
    ];
} 
