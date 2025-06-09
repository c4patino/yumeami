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
      apps = {
        forgejo = enabled;
        vaultwarden = enabled;
      };
      ci = {
        gitea-runner = {
          enable = true;
          runners."default" = {instances = 1;};
        };
      };
      metrics.grafana = enabled;
      networking.httpd = enabled;
      storage.samba.mounts = {
        "shared" = "arisu";
      };
    };
  };

  networking = {
    hostName = "shiori";
    hostId = "1a4ecbe3";
  };

  system.stateVersion = "25.11";
}
