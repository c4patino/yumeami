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
    (import ../../disko.nix {main = "/dev/mmcblk1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
    };
    services = {
      metrics = {
        ntfy = enabled;
        uptime-kuma = enabled;
      };

      networking = {
        blocky = enabled;
        cloudflared = enabled;
        httpd = enabled;
        unbound = enabled;
      };

      storage = {
        nfs = {
          enable = true;
          shares = [
            {
              name = "slurm";
              whitelist = ["arisu"];
              permissions = ["rw" "nohide" "insecure" "no_subtree_check" "no_root_squash" "sync"];
            }
          ];
        };
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
    hostName = "chibi";
    hostId = "9245f27e";
  };

  system.stateVersion = "25.05";
}
