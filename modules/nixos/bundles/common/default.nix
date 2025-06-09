{
  config,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    (import ./networking.nix args)
    (import ./users.nix args)
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "common bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      hardware.bootloader = enabled;

      services = {
        ci = {
          slurm = {
            enable = true;
            controlHosts = ["arisu" "chibi"];
            nodeMap = {
              arisu = {
                configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:rtx3070:1,shard:rtx3070:12 Weight=1";
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
              shiori = {
                configString = "CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=15500 Weight=5";
                partitions = ["main" "extended"];
              };
            };
          };
        };

        networking = {
          network-manager = enabled;
          tailscale = enabled;
        };

        security = {
          ca = enabled;
          gnupg = enabled;
          polkit = enabled;
          sops = enabled;
        };

        storage = {
          impermanence = enabled;
          postgresql = {
            databases = {
              shiori = ["grafana" "forgejo" "vaultwarden"];
            };
          };
          syncthing = {
            enable = true;
            devices = {
              arisu = "7W2TB7D-VZZEDAP-Q2LTH7S-LUF3JOC-472P4FX-ZUQX4SG-CLPTTK6-RVUP6QQ";
              kokoro = "7ADRQXW-IB3IMNR-QCT4EXQ-4BON25I-4EFPOW6-AVJNUZK-TEDMDZQ-RH37RAB";
              chibi = "HBLTAF3-GJ7G6XS-ER6IMAZ-CY2UI7S-6BG3N3S-GF4TDIC-7USNXW7-M6TWJQU";
              shiori = "BT76CBG-CZLKV2Q-S2ZGSPB-OC3KE66-HAHLDZ6-5W7GOOI-YNF6AXO-FU3N6AQ";
            };
            shares = {
              "shared" = ["arisu" "kokoro" "chibi" "shiori"];
            };
          };
        };
      };

      virtualization = {
        docker = enabled;
        podman = enabled;
      };
    };

    nix.settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];

    environment.systemPackages = with pkgs; [
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

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [stdenv.cc.cc];
    };

    systemd.tmpfiles.rules = [
      "d /mnt/sda 0755 c4patino users -"
      "d /mnt/sdb 0755 c4patino users -"
    ];
  };
}
