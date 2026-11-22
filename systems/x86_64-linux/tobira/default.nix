{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) disabled enabled;
in {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../../disko.nix {
      main = "/dev/vda";
      swapSize = "0";
    })
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      homelab = enabled;
      server = enabled;
    };

    hardware.bootloader = mkForce disabled;

    services.networking = {
      ddclient = {
        enable = true;
        zone = "cpatino.com";
        domains = [
          "*.cpatino.com"
        ];
      };

      registry.tobira.blocky.priority = mkForce 128;
    };

    virtualization = {
      docker = mkForce disabled;
      podman = mkForce disabled;
    };
  };

  boot.zfs.devNodes = "/dev/disk/by-path";

  networking = {
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "162.243.121.125";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "2604:a880:0:202a:0:1:77e2:5000";
          prefixLength = 64;
        }
      ];
    };

    defaultGateway = {
      address = "162.243.121.1";
      interface = "ens3";
    };

    defaultGateway6 = {
      address = "2604:a880:0:202a::1";
      interface = "ens3";
    };

    hostName = "tobira";
    hostId = "1042eb21";
  };
}
