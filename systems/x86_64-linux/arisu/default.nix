{
  config,
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
    hardware.nvidia = enabled;
    services = {
      apps = {
        rustypaste = enabled;
        glance = enabled;
      };
      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {instances = 1;};
        };

        github-runner = let
          inherit (config.sops) secrets;
        in {
          enable = true;
          runners = {
            "oasys-mas" = {
              tokenFile = secrets."github/runner-oasys".path;
              url = "https://github.com/oasys-mas";
            };
          };
        };
      };
      networking.httpd = enabled;
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
