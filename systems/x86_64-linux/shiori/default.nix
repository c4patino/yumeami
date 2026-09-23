{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce;
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
      server = enabled;
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
      };
      storage = {
        nfs.mounts = {
          servarr = {
            host = "nas";
            folder = "/volume1/servarr";
          };
          autobrr = {
            host = "arisu";
            folder = "/mnt/nfs/autobrr";
          };
        };
      };

      networking.network-services.shiori.blocky.priority = mkForce 128;
    };
  };

  networking = {
    hostName = "shiori";
    hostId = "1a4ecbe3";
  };

  system.stateVersion = "26.05";
}
