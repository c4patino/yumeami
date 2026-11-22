{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    ./users.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "common bundle";
  };

  config = mkIf cfg.enable {
    nix.settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      trusted-users = with config.users.users; [c4patino.name];

      auto-optimise-store = true;

      substituters = [
        # keep-sorted start
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://noctalia.cachix.org"
        # keep-sorted end
      ];

      trusted-public-keys = [
        # keep-sorted start
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        # keep-sorted end
      ];
    };

    boot = {
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "splash"
        "rd.system.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };

    environment.systemPackages = with pkgs; [
      cachix
      git
      home-manager
      nh
      nix-output-monitor
      nvd
    ];

    time.timeZone = "America/Chicago";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    programs = {
      bash = {
        enable = true;
        completion.enable = true;
      };

      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/sda 0755 c4patino users -"
      "d /mnt/sdb 0755 c4patino users -"
    ];

    system.stateVersion = "26.05";
  };
}
