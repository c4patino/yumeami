{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) listToAttrs;
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
      apps = {
        forgejo = enabled;
        glance = enabled;
        rustypaste = enabled;
        vaultwarden = enabled;
      };

      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {
            instances = 4;
          };
        };
        github-runner = {
          enable = true;
          runners = {
            "cseseniordesign" = {
              url = "https://github.com/cseseniordesign/dqc-r-and-s";
              instances = 4;
            };
          };
        };
        woodpecker = {
          enable = true;
          runners.primary = {
            enable = true;
            capacity = 4;
          };
        };
      };

      metrics = {
        grafana = enabled;
      };

      networking = {
        httpd = enabled;
      };

      storage = {
        samba.mounts = {
          "shared" = "arisu";
        };
      };
    };
  };

  networking = {
    hostName = "shiori";
    hostId = "1a4ecbe3";
  };

  system.stateVersion = "25.05";
}
