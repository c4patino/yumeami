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
    (import ../../disko.nix {main = "/dev/nvme0n1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      server = enabled;
    };

    hardware = {
      amd = enabled;
    };

    services = {
      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {
            capacity = 4;
          };
        };
        woodpecker.runners.primary = {
          enable = true;
          capacity = 4;
        };
      };

      storage = {
        samba.mounts = {
          shared = {
            host = "arisu";
            folder = "shared";
          };
        };
        nfs.mounts = {
          servarr = {
            host = "nas";
            folder = "/volume1/servarr";
          };
        };
      };
    };
  };

  networking = {
    hostName = "tsuki";
    hostId = "3d19e767";
  };

  system.stateVersion = "26.05";
}
