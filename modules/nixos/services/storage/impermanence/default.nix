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

          ".config/Google"
          ".config/JetBrains"
          ".config/Postman"
          ".config/Slack"
          ".config/VirtualBox"
          ".config/WebCord"
          ".config/autostart"
          ".config/gh"
          ".config/libreoffice"
          ".config/obs-studio"
          ".config/obsidian"
          ".config/opencode"
          ".config/pnpm"
          ".config/pypoetry"
          ".config/spotify"
          ".config/spotify-player"
          ".config/teamviewer"
          ".config/variety"
          ".config/vivaldi"

          ".gnupg"
          ".java"
          "Documents"
          "dotfiles"

          ".local/share/Google"
          ".local/share/JetBrains"
          ".local/share/PrismLauncher"
          ".local/share/Steam"
          ".local/share/applications"
          ".local/share/containers"
          ".local/share/direnv"
          ".local/share/nvim"
          ".local/share/opencode"
          ".local/share/pnpm"
          ".local/share/racket"
          ".local/share/zoxide"
          ".local/share/zsh"

          ".pm2"
          ".steam"
          ".vim"
          "Obsidian"
          "Pictures"
          "Programming"
          "VirtualBox VMs"

          ".zotero"
          "Zotero"
        ];

        files = [
          ".ssh/known_hosts"
        ];
      };
    };
  };
}
