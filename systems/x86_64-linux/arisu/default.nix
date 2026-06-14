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
      main = "/dev/nvme0n1";
      extras = [
        "/dev/nvme1n1"
        "/dev/nvme2n1"
      ];
    })
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      desktop = enabled;
    };

    hardware = {
      nvidia = enabled;
    };

    services = {
      apps = {
        rustypaste.client = enabled;
      };

      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {};
        };
        github-runner = {
          enable = true;
          runners = {
            "free-range-zoo" = {
              url = "https://github.com/oasys-mas/free-range-zoo";
            };
            "dev-free-range-zoo" = {
              url = "https://github.com/oasys-mas/dev-free-range-zoo";
              instances = 2;
            };
          };
        };
        woodpecker.runners.primary = {
          enable = true;
        };
      };

      storage = {
        samba = {
          enable = true;
          shares = ["shared"];
        };
        nfs.mounts = {
          slurm = {
            host = "chibi";
            folder = "/mnt/nfs/slurm";
          };
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
    loader.grub = {
      theme = inputs.dotfiles + "/vimix/4k";
      useOSProber = true;
    };
  };

  system.stateVersion = "26.05";
}
