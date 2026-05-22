{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    inputs.disko.nixosModules.default
    (import ../../disko.nix {main = "/dev/nvme0n1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
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

      networking = {
        cloudflared = enabled;
        httpd = enabled;
      };

      storage = {
        samba.mounts = {
          "shared" = "arisu";
        };
      };
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  networking = {
    hostName = "tsuki";
    hostId = "3d19e767";
  };

  system.stateVersion = "25.11";
}
