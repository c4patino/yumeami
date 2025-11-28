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
          };
        };
        woodpecker.runners.primary = {
          enable = true;
        };
      };

      storage = {
        nfs.mounts = {
          "slurm" = "chibi";
        };

        samba = {
          enable = true;
          shares = ["shared"];
        };

        impermanence.folders = [
          "/mnt/samba/shared"
        ];
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
