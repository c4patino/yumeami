{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mkAfter concatLists;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.storage.impermanence";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "impermanence";
      folders = mkOption {
        type = listOf str;
        default = [];
        description = "List of root folders to persist";
      };
    };

  config = mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;

    boot.initrd.postResumeCommands = mkAfter ''
      zfs rollback -r zroot/root@blank
    '';

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = let
        static = [
          "/opt"

          "/var/db/sudo/lectured"
          "/var/lib/nixos"
          "/var/log"
        ];
      in
        concatLists [static cfg.folders];

      users.c4patino = {
        directories = [
          ".android"
          "Android"

          ".cache/direnv"
          ".cache/spotify"
          ".cache/spotify-player"
          ".cache/vivaldi"

          ".conan2"

          ".config/autostart"
          ".config/gh"
          ".config/Google"
          ".config/JetBrains"
          ".config/libreoffice"
          ".config/obs-studio"
          ".config/obsidian"
          ".config/pnpm"
          ".config/Postman"
          ".config/pypoetry"
          ".config/Slack"
          ".config/spotify"
          ".config/spotify-player"
          ".config/teamviewer"
          ".config/variety"
          ".config/VirtualBox"
          ".config/vivaldi"
          ".config/WebCord"

          "Documents"
          "dotfiles"
          ".gnupg"
          ".java"

          ".local/share/applications"
          ".local/share/containers"
          ".local/share/direnv"
          ".local/share/Google"
          ".local/share/JetBrains"
          ".local/share/nvim"
          ".local/share/pnpm"
          ".local/share/PrismLauncher"
          ".local/share/racket"
          ".local/share/Steam"
          ".local/share/zoxide"
          ".local/share/zsh"

          "Obsidian"
          "Pictures"
          "Programming"
          ".pm2"
          ".steam"
          ".vim"
          "VirtualBox VMs"

          "Zotero"
          ".zotero"
        ];

        files = [
          ".ssh/known_hosts"
        ];
      };
    };
  };
}
