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
    (import ../../disko.nix {main = "/dev/sda";})
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
        blocky = enabled;
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
    hostName = "shiori";
    hostId = "1a4ecbe3";
  };

  system.stateVersion = "25.11";
}
