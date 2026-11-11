{
  config,
  inputs,
  lib,
  namespace,
  hostName,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  ${namespace} = {
    bundles = {
      wsl = enabled;
    };

    virtualization = {
      docker = enabled;
      podman = enabled;
    };

    services = {
      security = {
        ca = enabled;
        gnupg = enabled;
        polkit = enabled;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cachix
    git
    home-manager
    nh
    nix-output-monitor
    nvd
  ];

  users.users = {
    c4patino = {
      isNormalUser = true;
      description = "C4 Patino";
      extraGroups = [
        "dialout"
        "docker"
        "networkmanager"
        "podman"
        "systemd-journal"
        "wheel"
      ];

      hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";
    };
  };

  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  sops = let
    inherit (config.users.users) c4patino;
  in {
    secrets = {
      "ssl/ca/cert" = {};

      "master-password" = {
        owner = c4patino.name;
      };
    };

    age.keyFile = mkDefault "/persist${c4patino.home}/dotfiles/secrets/crypt/age/${hostName}/keys.txt";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

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

  networking = {
    hostName = "komorebi";
    hostId = "c6cc4687";
  };

  system.stateVersion = "26.05";
}
