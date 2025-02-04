{
  self,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
in {
  options.devices = lib.mkOption {
    description = "Mapping of device names to their hostnames and IPs.";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        IP = lib.mkOption {
          type = types.str;
          description = "The IP address of the device.";
        };
        hostName = lib.mkOption {
          type = types.str;
          description = "The hostname of the device.";
        };
      };
    });
  };

  imports = [
    ./core
    ./gaming
    ./hardware
    ./services
    ./virtualization
    ./hyprland.nix
    ./impermanence.nix
    ./secrets.nix
  ];

  config = {
    nix.settings.trusted-users = [
      "root"
      "c4patino"
    ];

    users.users.c4patino = {
      isNormalUser = true;
      description = "C4 Patino";
      extraGroups = ["networkmanager" "wheel" "vboxusers" "docker" "podman" "syncthing"];

      hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";

      openssh.authorizedKeys.keyFiles = [
        "${self}/secrets/crypt/arisu/id_ed25519.pub"
        "${self}/secrets/crypt/kokoro/id_ed25519.pub"
        "${self}/secrets/crypt/chibi/id_ed25519.pub"
      ];

      shell = pkgs.zsh;
    };

    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      packages = with pkgs; [
        corefonts
        nerd-fonts.meslo-lg
        nerd-fonts.caskaydia-cove
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
      ];
    };

    systemd.tmpfiles.rules = [
      "d /mnt/sda 0755 c4patino users -"
      "d /mnt/sdb 0755 c4patino users -"
    ];

    efi-bootloader.enable = true;
    impermanence.enable = true;
    network-manager.enable = true;
    containerization.enable = true;
    tailscale.enable = true;

    devices = {
      "arisu" = {
        hostName = "arisu";
        IP = "100.117.106.23";
      };
      "kokoro" = {
        hostName = "kokoro";
        IP = "100.69.45.111";
      };
      "chibi" = {
        hostName = "chibi";
        IP = "100.101.224.25";
      };
    };

    slurm = {
      enable = true;
      primaryHost = "arisu";
      nodeMap = {
        arisu = {
          configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:rtx3070:1,shard:12 Weight=1";
          partitions = ["main" "extended"];
        };
        kokoro = {
          configString = "CPUs=10 Sockets=1 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=23700 Weight=100";
          partitions = ["extended"];
        };
        chibi = {
          configString = "CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7750 Weight=10";
          partitions = ["main" "extended"];
        };
      };
    };

    syncthing = {
      enable = true;
      devices = {
        arisu = "7W2TB7D-VZZEDAP-Q2LTH7S-LUF3JOC-472P4FX-ZUQX4SG-CLPTTK6-RVUP6QQ";
        kokoro = "7ADRQXW-IB3IMNR-QCT4EXQ-4BON25I-4EFPOW6-AVJNUZK-TEDMDZQ-RH37RAB";
        chibi = "HBLTAF3-GJ7G6XS-ER6IMAZ-CY2UI7S-6BG3N3S-GF4TDIC-7USNXW7-M6TWJQU";
      };
      shares = {
        "shared" = ["arisu" "kokoro" "chibi"];
      };
    };
  };
}
