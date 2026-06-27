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
    (import ../../disko.nix {
      main = "/dev/nvme0n1";
      size = "512G";
    })
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      desktop = enabled;
    };

    hardware = {
      battery = enabled;
      camera = enabled;
      fingerprint = enabled;
      xremap = enabled;
    };

    services = {
      storage = {
        samba.mounts = {
          shared = {
            host = "arisu";
            folder = "shared";
          };
        };
      };
    };
  };

  networking = {
    hostName = "kokoro";
    hostId = "41f4c357";
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    loader.grub = {
      theme = inputs.dotfiles + "/vimix/2k";
      useOSProber = true;
    };
  };

  system.stateVersion = "26.05";
}
