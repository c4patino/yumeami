{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../../disko.nix {
      main = "/dev/nvme1n1";
      extras = ["/dev/nvme0n1" "/dev/nvme2n1"];
    })
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      desktop = enabled;
    };

    desktop = {
      apps = {
        teamviewer = enabled;
      };
    };

    hardware = {
      nvidia = enabled;
    };

    services = {
      apps = {
        rustypaste.client = enabled;

        servarr = {
          jellyfin = enabled;
          ombi = enabled;

          prowlarr = enabled;
          radarr = enabled;
          sonarr = enabled;
          lidarr = enabled;
          bazarr = enabled;
        };

        qbittorrent = enabled;
      };

      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {};
        };
        github-runner = {
          enable = true;
          runners = {
            "cseseniordesign" = {
              url = "https://github.com/cseseniordesign/dqc-r-and-s";
            };
            "free-range-zoo" = {
              url = "https://github.com/oasys-mas/free-range-zoo";
            };
            "dev-free-range-zoo" = {
              url = "https://github.com/oasys-mas/dev-free-range-zoo";
              instances = 2;
            };
          };
        };
        woodpecker.runners = {
          primary.enable = true;
        };
      };

      networking = {
        httpd = enabled;
      };

      storage = {
        nfs.mounts = {
          "slurm" = "chibi";
        };

        samba = {
          enable = true;
          shares = ["shared"];
        };
      };
    };
  };

  networking = {
    hostName = "arisu";
    hostId = "c6cc4687";
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    loader.grub.theme = inputs.dotfiles + "/vimix/4k";
  };

  system.stateVersion = "25.11";
}
