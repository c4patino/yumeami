{
  self,
  pkgs,
  config,
  hostName,
  ...
}: {
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

      openssh.authorizedKeys.keyFiles = let
        ssh = "${self}/secrets/crypt/ssh";
      in
        ["arisu" "chibi" "kokoro" "shiori"]
        |> map (h: "${ssh}/${h}/id_ed25519.pub");

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
    network-manager.enable = true;

    impermanence.enable = true;

    tailscale.enable = true;

    containerization.enable = true;

    network-services = {
      rustypaste = {
        host = "arisu";
        port = 5100;
      };
      dash = {
        host = "arisu";
        port = 5150;
      };

      uptime-kuma = {
        host = "chibi";
        port = 5200;
      };
      ntfy = {
        host = "chibi";
        port = 5201;
      };

      git = {
        host = "shiori";
        port = 5300;
      };
      vaultwarden = {
        host = "shiori";
        port = 5400;
      };
      grafana = {
        host = "shiori";
        port = 5500;
      };
    };

    unbound.dnsHost = "chibi";

    devices = {
      arisu = {
        IP = "100.117.106.23";
      };
      kokoro = {
        IP = "100.69.45.111";
      };
      chibi = {
        IP = "100.101.224.25";
      };
      shiori = {
        IP = "100.127.93.17";
      };
    };

    postgresql.databases = {
      shiori = ["grafana" "forgejo" "vaultwarden"];
    };

    slurm = {
      enable = true;
      controlHosts = ["arisu" "chibi"];
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
        shiori = {
          configString = "CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=15500 Weight=5";
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
        shiori = "BT76CBG-CZLKV2Q-S2ZGSPB-OC3KE66-HAHLDZ6-5W7GOOI-YNF6AXO-FU3N6AQ";
      };
      shares = {
        "shared" = ["arisu" "kokoro" "chibi" "shiori"];
      };
    };

    sops = let
      inherit (config.users.users) c4patino;
    in {
      secrets = {
        "master-password" = {owner = c4patino.name;};

        "forgejo" = {owner = c4patino.name;};

        "github/auth" = {owner = c4patino.name;};
        "github/runner" = {owner = c4patino.name;};
        "github/runner-oasys" = {owner = c4patino.name;};

        "tailscale/actions" = {owner = c4patino.name;};
        "tailscale/tsdproxy" = {owner = c4patino.name;};

        "cloudflare" = {owner = c4patino.name;};

        "pypi" = {owner = c4patino.name;};

        "rustypaste" = {owner = c4patino.name;};
      };

      age.keyFile = let
        crypt = "/persist/${c4patino.home}/dotfiles/secrets/crypt";
      in "${crypt}/age/${hostName}/keys.txt";
    };
  };
}
