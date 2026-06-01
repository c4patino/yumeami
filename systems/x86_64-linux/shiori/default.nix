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
      networking = {
        ddclient = {
          enable = true;
          zone = "cpatino.com";
          domains = [
            "*.cpatino.com"
          ];
        };
        httpd = enabled;
      };
      storage = {
        nfs.mounts = {
          jellyfin = {
            host = "nas";
            folder = "/volume1/jellyfin";
          };
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

  system.stateVersion = "26.05";
}
