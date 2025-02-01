{
  inputs,
  lib,
  config,
  ...
}: {
  options = {
    impermanence.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable impermanence";
    };
  };

  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];

  config = lib.mkIf config.impermanence.enable {
    home.persistence."/persist/home/c4patino" = {
      directories = [
        ".android"
        "Android"

        ".cache/direnv"
        ".cache/spotify"
        ".cache/spotify-player"
        ".cache/vivaldi"

        ".config/autostart"
        ".config/gh"
        ".config/Google"
        ".config/JetBrains"
        ".config/libreoffice"
        ".config/obsidian"
        ".config/obs-studio"
        ".config/Postman"
        ".config/Slack"
        ".config/teamviewer"
        ".config/variety"
        ".config/VirtualBox"
        ".config/vivaldi"
        ".config/WebCord"

        "Documents"

        "dotfiles"

        ".local/share/applications"
        ".local/share/containers"
        ".local/share/direnv"
        ".local/share/Google"
        ".local/share/JetBrains"
        ".local/share/nvim"
        ".local/share/PrismLauncher"
        ".local/share/Steam"
        ".local/share/zoxide"
        ".local/share/zsh"

        "Pictures"
        "Programming"

        ".steam"
        ".vim"
      ];
    };
  };
}
